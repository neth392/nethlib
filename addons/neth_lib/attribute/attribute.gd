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

## Emitted after the [param spec] was applied to this [Attribute]. It may
## or may not be active, see [method AttributeEffectSpec.is_active]. If the
## relative [AttributeEffect] is of [enum AttributEffect.DurationType.INSTANT] then
## [method has_effect] will return false for it.
signal effect_applied(spec: AttributeEffectSpec)

## Emitted after the [param spec] applied to this [Attribute] has successfully
## processed. Emitted AFTER [member value] has been "affected" by it. 
## Not emitted if processing was blocked by an [AttributeEffectCondition], for
##  that see [signal effect_proccess_blocked].[br]
## Only emitted if [member AttributeEffect.emit_processed_signal] is true for
## the spec.get_effect().
signal effect_processed(spec: AttributeEffectSpec)

## Emitted after the [param spec] applied to this [Attribute] has had its
## processing blocked by [param blocking_condition].[br]
## Only emitted if [member AttributeEffect.emit_process_blocked_signal] is true for
## the spec.get_effect().
signal effect_process_blocked(spec: AttributeEffectSpec, 
blocking_condition: AttributeEffectCondition)

## Emitted when an [AttributeEffect] that was previously applied was inactive but
## is now active due to meeting previously failed conditions.
signal dormant_effect_activated(spec: AttributeEffectSpec)

## Emitted when an [AttributeEffect] that was previously applied was active but
## is now inactive due to failing to meet previously met conditions.
signal active_effect_deactivated(spec: AttributeEffectSpec)

## Emitted when the [param spec] was removed, either manually or due to expiration.
signal effect_removed(spec: AttributeEffectSpec)

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
		
		if old_value != value && !Engine.is_editor_hint():
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
	# Reverse iteration of _effects for safe & efficient removal at expiration.
	for index: int in _effects_range:
		var spec: AttributeEffectSpec = _effects[index]
		
		if !spec.process(self, delta, current_frame):
			_remove_effect_spec_at_index(spec, index)
			pass


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


## Applies the [param spec], returning true if it was successfully
## applied, false if it wasn't due to an [AttributeEffectCondition] which can
## be 
func apply_effect_spec(spec: AttributeEffectSpec) -> bool:
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
	_update_effects_range()
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
	_effects.remove_at()
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
		_effects.erase(effect)
	else:
		_effect_counts[effect] = new_count
	
	effect_removed.emit(spec)


func _update_effects_range() -> void:
	_effects_range = range(_effects.size(), -1, -1)


func _to_string() -> String:
	return "Attribute(id:%s)" % id
