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

## Emitted when the value returned by [method get_current_value] changes.
signal current_value_changed(prev_current_value: float)

## Emitted when [member base_value] changes.
signal base_value_changed(prev_base_value: float)

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
@export var base_value: float:
	set(value):
		var prev_base_value: float = base_value
		base_value = _validate_base_value(value)
		
		if prev_base_value != base_value:
			if _emit_base_value_changed:
				base_value_changed.emit(prev_base_value)
				_base_value_changed(prev_base_value)
			
			update_current_value()
		
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
@export var _default_effects: Array[AttributeEffect] = []:
	set(value):
		_default_effects = value
		update_configuration_warnings()

## Whether or not [StaminaEffect]s with a duration should have their duration tick.
@export var tick_effect_durations: bool = true

## The [AttributeContainer] this attribute belongs to stored as a [WeakRef] for
## circular reference safety.
var _container: WeakRef

## Array of all added [AttributeEffectSpec]s that are of [enum AttributeEffect.Type.PERMANENT]
var _specs: Array[AttributeEffectSpec] = []
## Stores _effects range (in reverse) to iterate so it doesn't need to be 
## reconstructed every _process call.
var _specs_range: Array = [0]

## Dictionary of in the format of [code]{[member AttributeEffect.id] : int}[/code] count of all 
## applied [AttributeEffectSpec]s with that effect.
var _effect_counts: Dictionary = {}

## Internal flag used to mark if [signal base_value_changed] should be emitted or not.
var _emit_base_value_changed: bool = true
var _emit_current_value_changed: bool = true

## The internal current value
var _current_value: float:
	set(value):
		var prev_current_value: float = _current_value
		_current_value = _validate_current_value(value)
		if _current_value != prev_current_value && _emit_current_value_changed:
			current_value_changed.emit(prev_current_value)
			_current_value_changed(prev_current_value)
		update_configuration_warnings()

func _enter_tree() -> void:
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
	_process_effects(delta, Engine.get_process_frames(), _specs_range)


func _physics_process(delta: float) -> void:
	print("PHYISCS PROCESS")
	_process_effects(delta, Engine.get_physics_frames(), _specs_range)


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


func _process_effects(delta: float, current_frame: int, indexes: Array) -> void:
	var prev_base_value: float = base_value
	var prev_current_value: float = _current_value
	var emit_applied: Array[AttributeEffectSpec] = []
	var expired_specs: Dictionary = {}
	
	_emit_base_value_changed = false
	_emit_current_value_changed = false
	
	# Reverse iteration of _specs for safe & efficient removal during iteration.
	for index: int in indexes:
		var spec: AttributeEffectSpec = _specs[index]
		
		var already_processed: bool = spec._last_process_frame == current_frame
		if spec.get_effect().is_permanent() && already_processed:
			continue
		
		if spec.get_effect().has_process_conditions():
			spec._last_blocked_by = spec._can_process(self)
			if spec._last_blocked_by != null:
				spec._is_processing = false
				continue
		
		# Mark as processing
		spec._is_processing = true
		spec._last_process_frame = current_frame
		
		# Duration Calculations
		# (already_processed can only be false if the effect is temporary at this point)
		if !already_processed && spec.get_effect().has_duration():
			spec.remaining_duration -= delta
			spec._passed_duration += delta
			# Spec expired, remove it.
			if spec.remaining_duration <= 0.0:
				# Adjust remaining period as well
				spec.remaining_period -= delta
				spec._expired = true
				expired_specs[index] = spec
				continue
		
		if spec.get_effect().has_period():
			# Period Calculations
			spec.remaining_period -= delta
			# Can not yet activate, proceed to next
			if spec.remaining_period > 0.0:
				continue
			# Add to remaining period
			spec.remaining_period += spec._effect.get_modified_period(self, spec)
		
		# Check if can apply
		if spec.get_effect().has_apply_conditions():
			spec._last_blocked_by = spec.can_apply(self)
			if spec._last_blocked_by != null:
				if spec._last_blocked_by.emit_blocked_signal:
					effect_apply_blocked.emit(spec)
				continue
		
		if spec.get_effect().is_temporary() && prev_base_value == base_value:
			# Don't apply if temporary & there was no change to base value.
			continue
		
		# Apply efffect
		spec._last_apply_frame = current_frame
		spec._apply_count += 1
		spec._last_value = spec._effect.get_modified_value(self, spec)
		match spec._effect.type:
			AttributeEffect.Type.PERMANENT:
				base_value = spec._effect.apply_calculator(base_value, spec._last_value)
				spec._last_set_value = base_value
			AttributeEffect.Type.TEMPORARY:
				_current_value = spec._effect.apply_calculator(_current_value, spec._last_value)
				spec._last_set_value = _current_value
			_:
				assert(false, "no implementation for spec._effect.type %s" % spec._effect.type)
		
		# Add to emit list if it should be emitted
		if spec._effect.can_emit_apply_signal() && spec._effect.emit_applied_signal:
			emit_applied.append(spec)
	
	# Allow auto-signal emitting for values again
	_emit_base_value_changed = true
	_emit_current_value_changed = true
	
	# Emit value changed signals
	if prev_base_value != base_value:
		base_value_changed.emit(prev_base_value)
		_base_value_changed(prev_base_value)
	if prev_current_value != _current_value:
		current_value_changed.emit(prev_current_value)
		_current_value_changed(prev_current_value)
	
	# Emit applied signals
	for spec: AttributeEffectSpec in emit_applied:
		effect_applied.emit(spec)
	
	# Remove expired specs
	if !expired_specs.is_empty():
		for index: int in expired_specs:
			_remove_effect_spec_at_index(expired_specs[index], index, false)
		_update_specs_range()


## Called by the setter of [member base_value] with [param set_base_value] (what was manually
## set to [member base_value]). If the value fails any constraints it can be modified and
## returned, otherwise just return [param set_base_value].[br]
## Can also be used to emit events as this is [b]only[/b] called in the setter of 
## [member set_base_value].
func _validate_base_value(set_base_value: float) -> float:
	return set_base_value


## Called by the setter of [member _current_value] with [param set_current_value] (what was manually
## set to [member _current_value]). If the value fails any constraints it can be modified and
## returned, otherwise just return [param set_current_value].[br]
## Can also be used to emit events as this is [b]only[/b] called in the setter of 
## [member set_current_value].
func _validate_current_value(set_current_value: float) -> float:
	return set_current_value


## Called in the setter of [member base_value] after it has been set &
## after [signal emit_value_changed] has been admitted.
func _base_value_changed(prev_base_value: float) -> void:
	pass


## Called in the setter of [member _current_value] after it has been set &
## after [signal emit_value_changed] has been admitted.
func _current_value_changed(prev_current_value: float) -> void:
	pass


## Returns the [AttributeContainer] this [Attribute] belongs to, null if there
## is no container (which shouldn't happen with proper [Node] management).
func get_container() -> AttributeContainer:
	return _container.get_ref() as AttributeContainer


## Returns the current value, which is the [member base_value] affected by
## all [AttributeEffect]s of type [enum AttributeEffect.Type.TEMPORARY]
func get_current_value() -> float:
	return _current_value


## Updates the value returned by [method get_current_value] by re-executing all
## [AttributeEffect]s of type [enum AttributeEffect.Type.TEMPORARY] on the [member base_value].
func update_current_value() -> void:
	var _prev_current_value: float = _current_value
	_emit_current_value_changed = false
	_current_value = base_value
	
	for spec: AttributeEffectSpec in _specs:
		if !spec.get_effect().is_temporary():
			# We can break here because AttributeEffect.sort_ascending ensures
			# temporary effects are ALWAYS before permanent.
			break
		_current_value = spec.get_effect().calulate_value(self, spec)
	
	_emit_current_value_changed = true
	if _current_value != _prev_current_value:
		current_value_changed.emit(_prev_current_value)
		_current_value_changed(_prev_current_value)


func add_effect(effect: AttributeEffect) -> bool:
	return false ## TODO


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
	assert(spec.is_expired(), "spec (%s) already expired" % spec)
	
	# Check if it can be added
	if !_check_condition(spec, spec._can_add, effect_add_blocked):
		return false
	
	if spec.get_effect().is_instant():
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
	return _specs.has(spec)


## Manually removes the [param spec] from this [Attribute], returning true
## if successfully removed, false if not due to it not existing.
func remove_effect_spec(spec: AttributeEffectSpec) -> bool:
	assert(spec != null, "spec is null")
	var index: int = _specs.find(spec)
	if index < 0:
		return false
	
	# Only update the current value if it is a temporary effect & _update_current_value is true
	_remove_effect_spec_at_index(spec, index, spec._effect.is_temporary())
	return true


## More efficient function to remove an [AttributeEffectSpec] with a known [param index]
## in [member _effects].
func _remove_effect_spec_at_index(spec: AttributeEffectSpec, index: int, _update_current_value: bool) -> void:
	assert(spec != null, "spec is null")
	assert(spec._effect != null, "spec._effect is null")
	assert(index >= 0, "index(%s) < 0" % index)
	assert(index < _specs.size(), "index(%s) >= _specs.size() (%s)" % [index, _specs.size()])
	assert(_specs[index] == spec, "element @ index (%s) in _specs != spec (%s)" % [index, spec])
	assert(_effect_counts.has(spec._effect), "_effect_counts does not have effect (%s)" \
	% spec._effect)
	
	spec._is_processing = false
	spec._is_active = false
	_specs.remove_at(index)
	_update_specs_range()
	var new_count: int = _effect_counts[spec._effect] - 1
	if new_count <= 0:
		_effect_counts.erase(spec._effect)
	else:
		_effect_counts[spec._effect] = new_count
	
	if spec._effect.emit_removed_signal:
		effect_removed.emit(spec)
	
	if _update_current_value:
		update_current_value()


func _update_specs_range() -> void:
	_specs_range = range(_specs.size(), -1, -1)


func _check_condition(spec: AttributeEffectSpec, callable: Callable, _signal: Signal) -> bool:
	spec._last_blocked_by = callable.call(self)
	if spec._last_blocked_by != null:
		if spec._last_blocked_by.emit_blocked_signal && !_signal.is_null():
			_signal.emit(spec)
		return false
	return true


func _to_string() -> String:
	return "Attribute(id:%s)" % id
