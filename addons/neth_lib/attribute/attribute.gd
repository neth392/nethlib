## Represents a floating point value that can have [AttributeEffect]s
## applied to modify that value. Can also be extended with custom logic.
## [br]Note: When extending, if any of the following functions are overridden they
## MUST first call their super counterpart, unless you know what you're doing.
## [codeblock]
## super._enter_tree()
## super._ready()
## super._process(delta) # Only call when effects_process_function = PROCESS
## super._physics_process(delta) # Only call when effects_process_function = PHYSICS_PROCESS
## super._exit_tree()
## [/codeblock]
@tool
class_name Attribute extends Node

enum Property {
	VALUE,
}

## Which _process function is used to execute effects.
enum ProcessFunction {
	## [method Node._process] is used.
	PROCESS,
	## [method Node._phyics_process] is used.
	PHYSICS_PROCESS,
}

###################
## Value Signals ##
###################

## Emitted when the attribute value changes. [param old_value] is the value prior to the change.
signal value_changed(old_value: float)


####################
## Effect Signals ##
####################

## Emitted after the [param spec] was added to this [Attribute]. If the
## relative [AttributeEffect] is of [enum AttributEffect.DurationType.INSTANT] then
## [method has_effect] will return false when called with [param spec].
signal effect_added(spec: AttributeEffectSpec)

## Emitted after the [param spec] has been applied to this [Attribute], in processing
## or as an instant effect.
signal effect_applied(spec: AttributeEffectSpec)

## Emitted after the [param spec] was blocked from being added to
## this [Attribute] by an [AttributeEffectCondition]. To access the condition
## that blocked, call [method AttributeEffectSpec.get_denied_by].
signal effect_add_blocked(spec: AttributeEffectSpec)

## Emitted after the added [param spec] was blocked from being applied to
## this [Attribute] by an [AttributeEffectCondition]. To access the condition
## that blocked, call [method AttributeEffectSpec.get_denied_by].
signal effect_apply_blocked(spec: AttributeEffectSpec)

## Emitted when the [param spec] was removed. To determine if it was manual
## or due to expiration, see [method AttributeEffectSpec.expired].
signal effect_removed(spec: AttributeEffectSpec)

## Emitted when the [param spec] had its stack count changed.
signal effect_stack_count_changed(spec: AttributeEffectSpec, previous_stack_count: int)

## The ID of the attribute.
@export var id: StringName:
	set(_value):
		id = _value
		update_configuration_warnings()

## The attribute value.
@export var value: float:
	set(_value):
		var old_value: float = value
		value = _validate_value(_value)
		
		if _emit_value_changed && old_value != value && !Engine.is_editor_hint():
			value_changed.emit(old_value)
		
		_value_changed(old_value)
		
		update_configuration_warnings()
		return true

@export_group("Effects")

## Which [ProcessFunction] is used when processing [AttributeEffect]s.
@export var effects_process_function: ProcessFunction = ProcessFunction.PROCESS:
	set(_value):
		effects_process_function = _value
		if !Engine.is_editor_hint():
			set_process(effects_process_function == ProcessFunction.PROCESS)
			set_physics_process(effects_process_function == ProcessFunction.PHYSICS_PROCESS)

## Array of all [AttributeEffect]s.
@export var _default_effects: Array[AttributeEffect] = []

## Whether or not [StaminaEffect]s with a duration should have their duration tick.
@export var tick_effect_durations: bool = true

## The [AttributeContainer] this attribute belongs to stored as a [WeakRef] for
## circular reference safety.
var _container: WeakRef

## Array of all applied [AttributeEffectSpec]s.
var _effects: Array[AttributeEffectSpec] = []
## Stores _effects range (in reverse) to iterate so it doesn't need to be 
## reconstructed every _process call.
var _effects_range: Array = [0]

## Dictionary of in the format of [member AttributeEffect.id] : int count of all 
## applied [AttributeEffectSpec]s with that effect.
var _effect_counts: Dictionary = {}

## Internal flag used to mark if [signal value_changed] should be emitted or not.
var _emit_value_changed: bool = true

func _enter_tree() -> void:
	range()
	if Engine.is_editor_hint():
		return
	assert(get_parent() is AttributeContainer, "parent not of type AttributeContainer")
	_container = weakref(get_parent() as AttributeContainer)


func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)


func _process(delta: float) -> void:
	print("PROCESS")
	_process_effects(delta, Engine.get_process_frames())


func _physics_process(delta: float) -> void:
	print("PHYISCS PROCESS")
	_process_effects(delta, Engine.get_physics_frames())


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_container = null


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if id.is_empty():
		warnings.append("no ID set")
	if !(get_parent() is AttributeContainer):
		warnings.append("parent not of type AttributeContainer")
	else:
		for child in get_parent().get_children():
			if child is Attribute:
				if child != self && child.id == id:
					warnings.append("Sibling Attribute (%s) has the same ID" % child.name)
	if _default_effects.has(null):
		warnings.append("_default_effects has a null element")
	return warnings


func _process_effects(delta: float, current_frame: int) -> void:
	var previous_value: float = value
	var emit_applied: Array[AttributeEffectSpec] = []
	_emit_value_changed = false
	
	# Reverse iteration of _effects for safe & efficient removal during iteration.
	for index: int in _effects_range:
		var spec: AttributeEffectSpec = _effects[index]
		
		# Ensure spec wasn't processed this frame.
		if spec._last_process_frame == current_frame:
			continue
		
		# Ensure can process
		var process_block: AttributeEffectCondition = spec.can_process(self)
		if process_block != null:
			spec._is_processing = false
			spec._blocked_by = process_block
			continue
		
		# Mark as processing
		spec._is_processing = true
		spec._last_process_frame = current_frame
		
		# Duration Calculations
		if spec.has_duration():
			spec.remaining_duration -= delta
			# Spec expired, remove it.
			if spec.remaining_duration <= 0.0:
				# Adjust remaining period as well
				spec.remaining_period -= delta
				spec.remaining_duration = 0.0
				spec._expired = true
				_remove_effect_spec_at_index(spec, index)
				continue
		
		# Period Calculations
		spec.remaining_period -= delta
		# Can not yet activate, proceed to next
		if spec.remaining_period > 0.0:
			continue
		
		spec.remaining_period += spec.calculate
		
		var apply_block: AttributeEffectCondition = spec.can_apply(self)
		if apply_block != null:
			spec._blocked_by = apply_block
			if apply_block.emit_apply_blocked_signal:
				effect_apply_blocked.emit(spec)
			continue
		
			# DO ACTIVATE
		
		if !spec.process(self, delta, current_frame):
			_remove_effect_spec_at_index(spec, index)
			pass
	
	_emit_value_changed = true
	if previous_value != value:
		value_changed.emit(previous_value)
	for effect: AttributeEffectSpec in emit_applied:
		effect_applied.emit(effect)


## Called by the setter of [member value] with [param set_value] (what was manually
## set to [member value]). If the value fails any constraints it can be modified and
## returned, otherwise just return [param set_value].[br]
## Can also be used to emit events as this is [b]only[/b] called in the setter of 
## [member value].
func _validate_value(set_value: float) -> float:
	return set_value


## Called in the setter of [member value] after the new value has been set &
## after [signal value_changed] has been admitted.
func _value_changed(old_value: float) -> void:
	pass


## Returns the [AttributeContainer] this [Attribute] belongs to, null if there
## is no container (which shouldn't happen with proper [Node] management).
func get_container() -> AttributeContainer:
	return _container.get_ref() as AttributeContainer


## Adds & applies the [param spec], returning true if it was successfully
## added & applied, false if it wasn't due to an [AttributeEffectCondition]
## that was not met.
func add_effect_spec(spec: AttributeEffectSpec) -> bool:
	# Assert stack mode isnt DENY_ERROR, if it is assert it isn't a stack
	assert(spec._effect.stack_mode != AttributeEffect.StackMode.DENY_ERROR \
	or !has_effect(spec._effect), "stacking attempted on unstackable spec._effect (%s)" \
	% spec._effect)
	# Assert spec not already applied elsewhere
	assert(!spec.is_applied(), "spec (%s) already applied to an Attribute" % spec)
	
	if spec.get_effect().duration_type == AttributeEffect.DurationType.INSTANT:
		var blocking_condition: AttributeEffectCondition = spec.get_effect().can_apply(self)
		if blocking_condition != null:
			spec._last_denied_by = blocking_condition
			return false
		value = spec.calculate_value(self) # TODO Make sure this is good impl
		effect_applied.emit(spec)
		return true
	
	_effects.append(spec)
	_effects.sort_custom(AttributeEffectSpec.reverse_compare)
	_update_effects_range()
	
	if _effect_counts.has(spec.get_effect()):
		_effect_counts[spec.get_effect()] += 1
	else:
		_effect_counts[spec.get_effect()] = 1
	
	effect_applied.emit(spec)
	return true


## Returns true if the [param effect] is present and has one or more [AttributeEffectSpec]s
## applied to this [Attribute], false if not.
func has_effect(effect: AttributeEffect) -> bool:
	return _effect_counts.has(effect)


## Returns true if [param spec] is currently applied to this [Attribute], false if not.
func has_effect_spec(spec: AttributeEffectSpec) -> bool:
	return _effects.has(spec)


## Manually removes the [param spec] from this [Attribute], returning true
## if successfully removed, false if not due to it not existing.
func remove_effect_spec(spec: AttributeEffectSpec) -> bool:
	assert(spec != null, "spec is null")
	var index: int = _effects.find(spec)
	if index < 0:
		return false
	spec._is_active = false
	spec._expired = false
	_remove_effect_spec_at_index(spec, index)
	return true


## More efficient function to remove an [AttributeEffectSpec] with a known [param index]
## in [member _effects].
func _remove_effect_spec_at_index(spec: AttributeEffectSpec, index: int) -> void:
	assert(spec != null, "spec is null")
	assert(spec._effect != null, "spec._effect is null")
	assert(index >= 0, "index(%s) < 0" % index)
	assert(index < _effects.size(), "index(%s) >= _effects.size() (%s)" \
	% [index, _effects.size()])
	assert(_effect_counts.has(spec._effect), "_effect_counts does not have effect (%s)" \
	% spec._effect)
	
	_effects.remove_at(index)
	var new_count: int = _effect_counts[spec._effect] - 1
	if new_count <= 0:
		_effects.erase(spec.get_effect())
	else:
		_effect_counts[spec.get_effect()] = new_count
	
	effect_removed.emit(spec)


func _update_effects_range() -> void:
	_effects_range = range(_effects.size(), -1, -1)


func _to_string() -> String:
	return "Attribute(id:%s)" % id
