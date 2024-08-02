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

## Which _process function is used to execute effects.
enum ProcessFunction {
	## [method Node._process] is used.
	PROCESS = 0,
	## [method Node._phyics_process] is used.
	PHYSICS_PROCESS = 1,
	## No processing is used.
	NONE = 99,
}

## The result of adding an [AttributeEffectSpec] to an [Attribute].
enum AddEffectResult {
	## No attempt was ever made to add the Effect to an [Attribute].
	NEVER_ADDED = 0,
	## Effect was successfully added.
	ADDED = 1,
	## Effect was added to an existing [AttributeEffectSpec] via stacking.
	STACKED = 2,
	## Effect was blocked by an [AttributeEffectCondition], retrieve it via
	## [method get_last_blocked_by].
	BLOCKED_BY_CONDITION = 3,
	## Effect was already added to the [Attribute] and stack_mode is set to DENY.
	STACK_DENIED = 4,
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

## The base value of the attribute which permanent effects will apply to.
## [br]WARNING: Setting this directly can break the current value, use [method set_base_value].
@export var _base_value: float:
	set(value):
		var prev_base_value: float = _base_value
		_base_value = _validate_base_value(value)
		if prev_base_value != _base_value:
			base_value_changed.emit(prev_base_value)
			_base_value_changed(prev_base_value)
			if Engine.is_editor_hint():
				_update_current_value(_get_frames())
		
		update_configuration_warnings()

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

## The [AttributeContainer] this attribute belongs to stored as a [WeakRef] for
## circular reference safety.
var _container: WeakRef

## Array of all added [AttributeEffectSpec]s that are of [enum AttributeEffect.Type.PERMANENT]
var _permanent_specs: AttributeEffectSpecArray = \
AttributeEffectSpecArray.new(AttributeEffect.Type.PERMANENT)

## Array of all added [AttributeEffectSpec]s that are of [enum AttributeEffect.Type.TEMPORARY]
var _temporary_specs: AttributeEffectSpecArray =\
 AttributeEffectSpecArray.new(AttributeEffect.Type.TEMPORARY)

## Dictionary of in the format of [code]{[member AttributeEffect.id] : int}[/code] count of all 
## applied [AttributeEffectSpec]s with that effect.
var _effect_counts: Dictionary = {}

## The internal current value
var _current_value: float:
	set(value):
		var prev_current_value: float = _current_value
		_current_value = _validate_current_value(value)
		if _current_value != prev_current_value:
			current_value_changed.emit(prev_current_value)
			_current_value_changed(prev_current_value)
		update_configuration_warnings()

## Whether or not [method __core_loop] is currently running
var _locked: bool = false


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	assert(get_parent() is AttributeContainer, "parent not of type AttributeContainer")
	_container = weakref(get_parent() as AttributeContainer)


func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_container = null


func _process(delta: float) -> void:
	print("PROCESS")
	__core_loop(delta, Engine.get_process_frames())


func _physics_process(delta: float) -> void:
	print("PHYISCS PROCESS")
	__core_loop(delta, Engine.get_physics_frames())


## The heart & soul of Attribute, responsible for processing & applying [AttriubteEffectSpec]s.
## NOT meant to be overridden at all.
func __core_loop(delta: float, current_frame: int) -> void:
	assert(!_locked, "attribute is locked")
	_locked = true
	
	# Process PERMANENT effects
	_process_specs(_permanent_specs, current_frame, delta)
	# Process TEMPORARY effects
	var temp_spec_removed: bool = _process_specs(_temporary_specs, current_frame, delta)
	
	# Apply PERMANENT effects
	var base_value_changed: bool = _apply_permanent_specs(_permanent_specs, current_frame)
	
	if base_value_changed || temp_spec_removed:
		_update_current_value(current_frame)
	
	_locked = false


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


## Returns the [AttributeContainer] this [Attribute] belongs to, null if there
## is no container (which shouldn't happen with proper [Node] management).
func get_container() -> AttributeContainer:
	return _container.get_ref() as AttributeContainer


## Returns the base value of this attribute.
func get_base_value() -> float:
	return _base_value


## Sets the base value, also updating the current value.
func set_base_value(new_base_value: float) -> void:
	if _base_value != new_base_value:
		_base_value = new_base_value
		_update_current_value(_get_frames())


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


## Returns the current value, which is the [member base_value] affected by
## all [AttributeEffect]s of type [enum AttributeEffect.Type.TEMPORARY]
func get_current_value() -> float:
	return _current_value


## Applies all permanent specs whose _flag_should_apply is true. Returns true if
## base value was changed, false if not.
func _apply_permanent_specs(spec_array: AttributeEffectSpecArray, current_frame: int) -> bool:
	assert(spec_array.get_type() == AttributeEffect.Type.PERMANENT, 
	"spec_array.get_type() (%s) != PERMANENT" % spec_array.get_type())
	var new_base_value: float = _base_value
	for index: int in spec_array.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = spec_array.get_at_index(index)
		# Apply spec
		if _apply_permanent_spec(spec, current_frame, new_base_value):
			new_base_value = spec._last_set_value
	
	if _base_value != new_base_value:
		_base_value = new_base_value
		return true
	return false


## Applies [param spec] based on the [param new_base_value], setting what should be the
## new base value to [member AttributeEffectSpec._last_set_value].
## [br]NOTE: Does NOT set [member base_value].
func _apply_permanent_spec(spec: AttributeEffectSpec, current_frame: int, new_base_value: float) -> bool:
	assert(spec.get_effect().is_permanent(), "spec (%s) is not PERMANENT" % spec)
	# Check if it should apply (has it's flag set to true & passes all conditions)
	if !spec._flag_should_apply || !_check_apply_conditions(spec):
		return false
	# Set flag back to false
	spec._flag_should_apply = false
	spec._last_apply_frame = current_frame
	spec._apply_count += 1
	spec._last_value = spec.get_effect().get_modified_value(self, spec)
	spec._last_set_value = spec.get_effect().apply_calculator(new_base_value, 
	_current_value, spec._last_value)
	
	# Emit signal if necessary
	if spec.get_effect().can_emit_apply_signal() && spec.get_effect().emit_applied_signal:
		effect_applied.emit(spec)
	return true


## Updates the value returned by [method get_current_value] by re-applying all
## [AttributeEffect]s of type [enum AttributeEffect.Type.TEMPORARY].
func _update_current_value(current_frame: int) -> void:
	var new_current_value: float = _base_value
	
	for index: int in _temporary_specs.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = _temporary_specs.get_at_index(index)
		spec._apply_count += 1
		spec._last_apply_frame = current_frame
		spec._last_value = spec.get_effect().get_modified_value(self, spec)
		new_current_value = spec.get_effect().apply_calculator(_base_value, new_current_value, spec._last_value)
	
	if _current_value != new_current_value:
		_current_value = new_current_value


func _get_effect_array(effect: AttributeEffect) -> AttributeEffectSpecArray:
	assert(effect != null, "effect is null")
	match effect.type:
		AttributeEffect.Type.PERMANENT:
			return _permanent_specs
		AttributeEffect.Type.TEMPORARY:
			return _temporary_specs
		_:
			assert(false, "no implementation for effect.type (%s)" % effect.type)
			return null


## Returns true if the [param effect] is present and has one or more [AttributeEffectSpec]s
## applied to this [Attribute], false if not.
func has_effect(effect: AttributeEffect) -> bool:
	assert(effect != null, "effect is null")
	return _effect_counts.has(effect)


## Returns true if [param spec] is currently applied to this [Attribute], false if not.
func has_spec(spec: AttributeEffectSpec) -> bool:
	assert(spec != null, "spec is null")
	return _get_effect_array(spec.get_effect()).has(spec)


## Returns a new [Array] of all [AttributeEffectSpec]s whose 
## [method AttributEffectSpec.get_effect] equals [param effect].
func find_specs(effect: AttributeEffect) -> Array[AttributeEffectSpec]:
	var specs: Array[AttributeEffectSpec] = []
	var array: AttributeEffectSpecArray = _get_effect_array(effect)
	for index: int in array.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = array.get_at_index(index)
		if spec.get_effect() == effect:
			specs.append(spec)
			continue
	return specs


## Creates an [AttributeEffectSpec] from the [param effect] via [method AttriubteEffect.to_spec]
## and then calls [method add_specs]
func add_effect(effect: AttributeEffect) -> void:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	add_effects([effect])


## Creates an [AttributeEffectSpec] from each of the [param effects] via 
## [method AttriubteEffect.to_spec] and then calls [method add_specs]
func add_effects(effects: Array[AttributeEffect]) -> void:
	assert(!effects.has(null), "effects has null element")
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	var specs: Array[AttributeEffectSpec] = []
	for effect: AttributeEffect in effects:
		specs.append(effect.to_spec())
	add_specs(specs)


## Adds [param spec] to a new [Array], then calls [method add_specs]
func add_spec(spec: AttributeEffectSpec) -> void:
	assert(spec != null, "spec is null")
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	add_specs([spec])


## Adds (& possibly applies) of each of the [param specs].
## [br][b]There are multiple considerations when calling this function:[/b]
## [br]  - If a spec is PERMANENT, it is applied when it is added unless the spec has an initial period.
## [br]  - If TEMPORARY, it is not applied, however the current_value is updated instantly.
## [br]  - If INSTANT, it is not added, only applied.
## [br]  - If not already initialized (see [method AttributeEffectSpec.is_initialized])
##  it is not re-initialized unless [param re_init] is true.
## [br]  - If stack_mode is COMBINE and the effect already exists, the [param spec]'s
## stack_count will be added to the existing spec and [param spec] will NOT be added or intialized.
func add_specs(specs: Array[AttributeEffectSpec]) -> void:
	assert(!specs.is_empty(), "specs is empty")
	assert(!specs.has(null), "specs has null element")
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	
	_locked = true
	var new_perm_specs: AttributeEffectSpecArray = \
	AttributeEffectSpecArray.new(AttributeEffect.Type.PERMANENT)
	var new_temp_specs:  AttributeEffectSpecArray = \
	AttributeEffectSpecArray.new(AttributeEffect.Type.TEMPORARY)
	
	# Initialize specs
	# Sort specs into arrays ordered by priority
	# Set permanent specs to apply if they should
	for spec: AttributeEffectSpec in specs:
		assert(spec != null, "specs has null element")
		# Initialize if not done so
		if !spec.is_initialized():
			spec._initialize(self)
		match spec.get_effect().type:
			AttributeEffect.Type.PERMANENT:
				# Determine if it should be applied (if instant, or remaining period < 0)
				if spec.get_effect().is_instant() \
				or (spec.get_effect().has_period() && spec.remaining_period <= 0):
					spec._flag_should_apply = true
				
				new_perm_specs.add(spec)
			AttributeEffect.Type.TEMPORARY:
				new_temp_specs.add(spec)
			_:
				assert(false, "no implementation for type (%s)" % spec.get_effect())
	
	new_perm_specs.update_reversed_range()
	new_temp_specs.update_reversed_range()
	
	# Add specs
	_add_spec_array(new_perm_specs, _permanent_specs)
	_add_spec_array(new_temp_specs, _temporary_specs)
	
	var current_frame: int = _get_frames()
	
	# Apply permanent specs
	var base_value_changed: bool = _apply_permanent_specs(new_perm_specs, current_frame)
	
	# Update current value if perm specs were applied & 
	if base_value_changed || !new_temp_specs.is_empty():
		_update_current_value(current_frame)
	
	_locked = false


func _add_spec_array(new_specs: AttributeEffectSpecArray, target_array: AttributeEffectSpecArray) -> void:
	for index: int in new_specs.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = new_specs.get_at_index(index)
		# Do not add instant specs
		if spec.get_effect().is_instant():
			continue
		target_array.add(spec, false)
	target_array.update_reversed_range()


func remove_effect(effect: AttributeEffect) -> void:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	_locked = true
	var array: AttributeEffectSpecArray = _get_effect_array(effect)
	var removed: bool = false
	for index: int in array.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = array.get_at_index(index)
		if spec.get_effect() == effect:
			array.remove_at(index, false)
			_set_spec_removed(spec)
			removed = true
	
	if removed:
		array.update_reversed_range()
		if effect.is_temporary():
			_update_current_value(_get_frames())
	_locked = false


func remove_effects(effects: Array[AttributeEffect]) -> void:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	_locked = true
	_remove_by_effect(_permanent_specs, func (effect) -> bool: return effects.has(effect))
	if _remove_by_effect(_temporary_specs, func (effect) -> bool: return effects.has(effect)):
		_update_current_value(_get_frames())
	_locked = false


func _remove_by_effect(array: AttributeEffectSpecArray, effect_callable: Callable) -> bool:
	var removed: bool = false
	for index: int in array.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = array.get_at_index(index)
		if effect_callable.call(spec.get_effect()):
			array.remove_at(index, false)
			_set_spec_removed(spec)
			removed = true
	
	if removed:
		array.update_reversed_range()
	return removed


## Manually removes all [param specs] from this [Attribute].
func remove_specs(specs: Array[AttributeEffectSpec]) -> void:
	assert(!specs.has(null), "spec is null")
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	
	_locked = true
	
	_locked = false


## Manually removes all [AttributeEffectSpec]s, or instantly removes them if
## [method is_in_process_loop] returns false.
func remove_all_effects() -> void:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	_locked = true
	var perm_specs: Array[AttributeEffectSpec] = _permanent_specs._array.duplicate(false)
	var temp_specs: Array[AttributeEffectSpec] = _temporary_specs._array.duplicate(false)
	_permanent_specs.clear()
	_temporary_specs.clear()
	_effect_counts.clear()
	_set_specs_removed(perm_specs)
	_set_specs_removed(temp_specs)
	_current_value = _base_value
	_locked = false


func _set_specs_removed(specs: Array[AttributeEffectSpec]) -> void:
	for spec: AttributeEffectSpec in specs:
		_set_specs_removed(spec)


func _pre_remove_spec(spec: AttributeEffectSpec) -> void:
	spec._is_added = false
	spec._is_processing = false
	spec._run_callbacks(AttributeEffectCallback._Function.REMOVED, self)
	if spec.get_effect().emit_removed_signal:
		effect_removed.emit(spec)


func _post_remove_spec(spec: AttributeEffectSpec) -> void:
	spec._run_callbacks(AttributeEffectCallback._Function.PRE_REMOVE, self)


### More efficient function to remove an [AttributeEffectSpec] with a known [param index]
### in [member _specs].
#func _remove_spec_at_index(array: AttributeEffectSpecArray, spec: AttributeEffectSpec, 
#index: int, current_frame: int, _update_current_value: bool, _update_reverse_range: bool) -> void:
	#assert(spec != null, "spec is null")
	#assert(spec._is_added, "spec._is_added is false (%s)" % spec)
	#assert(spec.get_effect() != null, "spec.get_efect() returned null")
	#assert(index >= 0, "index(%s) < 0" % index)
	#assert(index < array.size(), "index(%s) >= array.size() (%s)" % [index, array.size()])
	#assert(array.get_at_index(index) == spec, "element @ index (%s) in array != spec (%s)" \
	#% [index, spec])
	#assert(_effect_counts.has(spec.get_effect()), "_effect_counts does not have effect (%s)" \
	#% spec.get_effect())
	#
	#var effect: AttributeEffect = spec.get_effect()
	#
	#spec._is_processing = false
	#spec._is_added = false
	#array.remove_at(index, _update_reverse_range)
	#
	#var new_count: int = _effect_counts[effect] - 1
	#if new_count <= 0:
		#_effect_counts.erase(effect)
	#else:
		#_effect_counts[effect] = new_count
	#
	#if effect.emit_removed_signal:
		#effect_removed.emit(spec)
	#
	#if effect.is_temporary() && _update_current_value:
		#_update_current_value(current_frame)


func _check_add_conditions(spec: AttributeEffectSpec) -> bool:
	if _check_conditions(spec, spec._can_add, effect_add_blocked):
		return true
	spec._last_add_result = AddEffectResult.BLOCKED_BY_CONDITION
	return false


func _check_apply_conditions(spec: AttributeEffectSpec) -> bool:
	return _check_conditions(spec, spec._can_apply, effect_apply_blocked)


func _check_process_conditions(spec: AttributeEffectSpec) -> bool:
	return _check_conditions(spec, spec._can_process, Signal())


func _check_conditions(spec: AttributeEffectSpec, callable: Callable, _signal: Signal) -> bool:
	spec._last_blocked_by = callable.call(self)
	if spec._last_blocked_by != null:
		if spec._last_blocked_by.emit_blocked_signal && !_signal.is_null():
			_signal.emit(spec)
		return false
	return true


## Returns true if spec was removed, false if not.
func _process_specs(specs: AttributeEffectSpecArray, current_frame: int, delta: float) -> bool:
	var spec_removed: bool = false
	for index: int in specs.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = specs.get_at_index(index)
		var effect: AttributeEffect = spec.get_effect()
		spec._flag_should_apply = false
		
		var already_processed: bool = spec._last_process_frame == current_frame
		if effect.is_permanent() && already_processed:
			continue
		
		# Check if can process
		if !_check_process_conditions(spec):
			spec._is_processing = false
			continue
		
		# Mark as processing
		spec._is_processing = true
		spec._last_process_frame = current_frame
		
		# Duration Calculations
		# (already_processed can only be false if the effect is temporary at this point)
		if !already_processed:
			# Keep track of passed duration for infinite as well
			spec._passed_duration += delta
			if effect.has_duration():
				spec.remaining_duration -= delta
				# Spec expired, remove it.
				if spec.remaining_duration <= 0.0:
					# Adjust remaining period as well
					spec.remaining_period -= delta
					spec._expired = true
					_remove_spec_at_index(specs, spec, index, current_frame, false, false)
					spec_removed = true
					continue
		
		if effect.has_period():
			# Period Calculations
			spec.remaining_period -= delta
			# Can not yet activate, proceed to next
			if spec.remaining_period > 0.0:
				continue
			# Add to remaining period
			spec.remaining_period += effect.get_modified_period(self, spec)
		
		spec._flag_should_apply = true
	
	if spec_removed:
		specs.update_reversed_range()
	return spec_removed


## Gets the current frame count based on [member effects_process_function]
func _get_frames() -> int:
	match effects_process_function:
		ProcessFunction.PROCESS:
			return Engine.get_process_frames()
		ProcessFunction.PHYSICS_PROCESS:
			return Engine.get_physics_frames()
		_:
			assert(false, "no implementation for effects_process_function (%s)" % effects_process_function)
			return 0


func _to_string() -> String:
	return "Attribute(id:%s)" % id
