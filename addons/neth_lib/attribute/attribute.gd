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

static func _sort_a_before_b(a: AttributeEffect, b: AttributeEffect) -> bool:
	if a.type != b.type:
		# PERMANENT before TEMPORARY
		return a.type == AttributeEffect.Type.PERMANENT
	# If same type, sort by priority
	return a.priority > b.priority

## Which _process function is used to execute effects.
enum ProcessFunction {
	## [method Node._process] is used.
	PROCESS = 0,
	## [method Node._phyics_process] is used.
	PHYSICS_PROCESS = 1,
	## No processing is enabled.
	NONE = 2,
}

## The result of adding an [AttributeEffectSpec] to an [Attribute].
enum EffectResult {
	## No attempt was ever made to add the Effect to an [Attribute].
	NEVER_ADDED = 0,
	## Effect was successfully added.
	SUCCESS = 1,
	## Effect was blocked by an [AttributeEffectCondition], retrieve it via
	## [method get_last_blocked_by].
	BLOCKED_BY_CONDITION = 2,
	## Effect was already added to the [Attribute] and stack_mode is set to DENY.
	STACK_DENIED = 3,
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
			base_value_changed.emit(prev_base_value)
			_base_value_changed(prev_base_value)
			if !_in_process_loop:
				_update_current_value()
		
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

## The [AttributeContainer] this attribute belongs to stored as a [WeakRef] for
## circular reference safety.
var _container: WeakRef

## Array of all added [AttributeEffectSpec]s that are of [enum AttributeEffect.Type.PERMANENT]
var _specs: Array[AttributeEffectSpec] = []

## Stores _effects range (in reverse) to iterate so it doesn't need to be 
## reconstructed every _process call.
var _specs_range_reverse: Array = [0]

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

## Whether or not [method __process] is currently running
var _in_process_loop: bool = false

## Callables to execute after [method __process] is running.
var _after_process_callables: Array[Callable] = []

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
	__process(delta, Engine.get_process_frames())


func _physics_process(delta: float) -> void:
	print("PHYISCS PROCESS")
	__process(delta, Engine.get_physics_frames())


func __process(delta: float, current_frame: int) -> void:
	assert(!_in_process_loop, "already in __process loop")
	_in_process_loop = true
	var update_range: bool = false
	var force_update_current_value: bool = false
	
	# Process effects
	for index: int in _specs_range_reverse:
		var spec: AttributeEffectSpec = _specs[index]
		
		_process_effect(spec, current_frame, delta)
		if spec._expired:
			update_range = true
			if spec.get_effect().is_temporary():
				# Temporary effect is removed, force update current value
				force_update_current_value = true
			_remove_effect_at_index(spec, index, false)
	
	if update_range:
		_update_specs_range_reverse()
	
	var new_base_value: float = base_value
	var new_current_value: float = base_value
	var emit_applied: Array[AttributeEffectSpec] = []
	# Apply effects
	for spec: AttributeEffectSpec in _specs:
		if !spec._flag_should_apply || !spec._can_apply(self):
			continue
		
		# Don't apply if temporary, no temporary effect was removed, AND base value hasn't changed.
		if spec.get_effect().is_temporary() && \
		(!force_update_current_value && new_base_value == base_value):
			continue
		
		# Apply the effect
		_set_apply_properties(spec, new_base_value, new_current_value, current_frame)
		match spec.get_effect().type:
			AttributeEffect.Type.PERMANENT:
				new_base_value = spec._last_set_value
			AttributeEffect.Type.TEMPORARY:
				new_current_value = spec._last_set_value
			_:
				assert(false, "no implementation written for spec.get_effect().type (%s)" \
				% spec.get_effect().type)
		
		# Add to emit list if it should be emitted
		if spec.get_effect().can_emit_apply_signal() && spec.get_effect().emit_applied_signal:
			emit_applied.append(spec)
	
	
	# Set new values if changed
	if base_value != new_base_value:
		base_value = new_base_value
	
	if _current_value != new_current_value:
		_current_value = new_current_value
	
	# Emit applied signals
	for spec: AttributeEffectSpec in emit_applied:
		effect_applied.emit(spec)
	
	# Execute post process callables
	_in_process_loop = false
	if !_after_process_callables.is_empty():
		var callables: Array[Callable] = _after_process_callables.duplicate(false)
		_after_process_callables.clear()
		for callable: Callable in _after_process_callables:
			callable.call()


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


## Returns true if currently in the process loop, false if not. While in the
## process loop, certain function calls are "queued" and automatically called after
## the loop is complete.
func is_in_process_loop() -> bool:
	return _in_process_loop


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
func _update_current_value() -> void:
	var new_current_value: float = base_value
	
	for spec: AttributeEffectSpec in _specs:
		var effect: AttributeEffect = spec.get_effect()
		if !effect.is_temporary():
			continue
		var effect_value: float = effect.get_modified_value(self, spec)
		new_current_value = effect.apply_calculator(base_value, new_current_value, effect_value)
	
	if _current_value != new_current_value:
		_current_value = new_current_value


## Queues the addition (& application if PERMANENT) of the [param spec], unless
## [method is_in_process_loop] is false, then the addition/application occurs instantly.
## [br][b]There are multiple considerations when calling this function:[/b]
## [br]  - If PERMANENT, effect is applied when it is added unless the spec has a pre-set period.
## [br]  - If TEMPORARY, it is not applied, however the current_value is updated instantly.
## [br]  - If INSTANT, it is not added, only applied.
## [br]  - If not already initialized (see [method AttributeEffectSpec.is_initialized])
##  it is not re-initialized unless [param re_init] is true.
## [br]  - If stack_mode is COMBINE and the effect already exists, the [param spec]'s
## stack_count will be added to the existing spec and [param spec] will NOT be added or intialized.
func queue_add_effect(spec: AttributeEffectSpec) -> void:
	assert(spec != null, "specs_to_add has null element")
	
	if _in_process_loop:
		_after_process_callables.append(queue_add_effect.bind(spec))
		return
	
	var effect: AttributeEffect = spec.get_effect()
	# Assert stack mode isnt DENY_ERROR, if it is assert it isn't a stack
	assert(effect.stack_mode != AttributeEffect.StackMode.DENY_ERROR || !has_effect(effect),
	"stacking attempted on unstackable effect (%s)" % effect)
	
	# Assert spec not already applied elsewhere
	assert(!spec.is_applied(), "spec (%s) already applied to an Attribute" % spec)
	assert(spec.is_expired(), "spec (%s) already expired" % spec)
	
	# Check if it isn't seperate stacking & exists already
	if effect.stack_mode != AttributeEffect.StackMode.SEPERATE && has_effect(effect):
		
		# Check if it can't be stacked
		if effect.stack_mode == AttributeEffect.StackMode.DENY \
		# Leave below line here for release more (assert above doesnt run there)
		or effect.stack_mode == AttributeEffect.StackMode.DENY_ERROR:
			# Can't stack
			spec._last_add_result = EffectResult.STACK_DENIED
			return
		
		# Check if it should be combined
		if effect.stack_mode == AttributeEffect.StackMode.COMBINE:
			# Check if it can be added before combining
			if !_check_add_conditions(spec):
				return
			var existing_spec: AttributeEffectSpec
			for other_spec: AttributeEffectSpec in _specs:
				if other_spec.get_effect() == effect:
					existing_spec = other_spec
					break
			assert(existing_spec != null, "no existing_spec found for effect (%s)" % effect)
			existing_spec._add_to_stack(self, spec._stack_count)
			return
	
	# Check if it can be added
	if !_check_add_conditions(spec):
		return
	
	# If not instant, add & initialize
	if !effect.is_instant():
		var added: bool = false
		for index: int in _specs.size():
			var other_spec: AttributeEffectSpec = _specs[index]
			if _sort_a_before_b(effect, other_spec.get_effect()):
				_specs.insert(index, spec)
				added = true
				break
		if !added:
			_specs.append(spec)
		spec._is_added = true
		if effect.emit_added_signal:
			effect_added.emit(spec)
	
		# Intialize it if not already done
		if !spec.is_initialized():
			_initialize_spec(spec)
	
	# Apply spec
	# TODO


## Returns true if the [param effect] is present and has one or more [AttributeEffectSpec]s
## applied to this [Attribute], false if not.
func has_effect(effect: AttributeEffect) -> bool:
	return _effect_counts.has(effect)


## Returns true if [param spec] is currently applied to this [Attribute], false if not.
func has_effect_spec(spec: AttributeEffectSpec) -> bool:
	return _specs.has(spec)


## Queues the manual removal of [param spec] from this [Attribute], or done instantly
## if [method is_in_process_loop] returns false.
func queue_remove_effect(spec: AttributeEffectSpec) -> void:
	assert(spec != null, "spec is null")
	assert(spec._is_added, "spec._is_added is false")
	
	if _in_process_loop:
		_after_process_callables.append(queue_add_effect.bind(spec))
		return
	
	var index: int = _specs.find(spec)
	if index < 0:
		return
	
	# Only update the current value if it is a temporary effect & _update_current_value is true
	_remove_effect_at_index(spec, index, spec.get_effect().is_temporary(), true)


## Queues the removal of all [AttributeEffectSpec]s, or instantly removes them if
## [method is_in_process_loop] returns false.
func queue_remove_all_effects() -> void:
	if is_in_process_loop():
		_after_process_callables.append(queue_remove_all_effects)
		return
	var specs: Array[AttributeEffectSpec] = _specs.duplicate(false)
	_specs.clear()
	_effect_counts.clear()
	_update_specs_range_reverse()
	for spec: AttributeEffectSpec in specs:
		spec._is_added = false
		spec._is_processing = false
		if spec.get_effect().emit_removed_signal:
			effect_removed.emit(spec)


## More efficient function to remove an [AttributeEffectSpec] with a known [param index]
## in [member _specs].
func _remove_effect_at_index(spec: AttributeEffectSpec, index: int, 
_update_current_value: bool, _update_range: bool = false) -> void:
	assert(spec != null, "spec is null")
	assert(spec._is_added, "spec._is_added is false (%s)" % spec)
	assert(spec.get_effect() != null, "spec.get_efect() returned null")
	assert(index >= 0, "index(%s) < 0" % index)
	assert(index < _specs.size(), "index(%s) >= _specs.size() (%s)" % [index, _specs.size()])
	assert(_specs[index] == spec, "element @ index (%s) in _specs != spec (%s)" % [index, spec])
	assert(_effect_counts.has(spec.get_effect()), "_effect_counts does not have effect (%s)" \
	% spec.get_effect())
	
	var effect: AttributeEffect = spec.get_effect()
	
	spec._is_processing = false
	spec._is_added = false
	_specs.remove_at(index)
	if _update_range:
		_update_specs_range_reverse()
	
	var new_count: int = _effect_counts[effect] - 1
	if new_count <= 0:
		_effect_counts.erase(effect)
	else:
		_effect_counts[effect] = new_count
	
	if effect.emit_removed_signal:
		effect_removed.emit(spec)
	
	if effect.is_temporary() && _update_current_value:
		_update_current_value()


func _update_specs_range_reverse() -> void:
	_specs_range_reverse = range(_specs.size(), -1, -1)


func _initialize_spec(spec: AttributeEffectSpec) -> void:
	assert(spec != null, "spec is null")
	var effect: AttributeEffect = spec.get_effect()
	if effect.has_period():
		spec.remaining_period = effect.get_modified_period(self, spec)
	if effect.has_duration():
		spec.remaining_duration = effect.get_modified_duration(self, spec)
	spec._initialized = true


func _check_add_conditions(spec: AttributeEffectSpec) -> bool:
	if _check_conditions(spec, spec._can_add, effect_add_blocked):
		return true
	spec._last_add_result = EffectResult.BLOCKED_BY_CONDITION
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


func _process_effect(spec: AttributeEffectSpec, current_frame: int, delta: float) -> void:
	var effect: AttributeEffect = spec.get_effect()
	spec._flag_should_apply = false
	
	var already_processed: bool = spec._last_process_frame == current_frame
	if effect.is_permanent() && already_processed:
		return
	
	# Check if can process
	if !_check_process_conditions(spec):
		spec._is_processing = false
		return
	
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
				return
	
	if effect.has_period():
		# Period Calculations
		spec.remaining_period -= delta
		# Can not yet activate, proceed to next
		if spec.remaining_period > 0.0:
			return
		# Add to remaining period
		spec.remaining_period += effect.get_modified_period(self, spec)
	
	spec._flag_should_apply = true


# Sets various properties when the effect is to be applied.
func _set_apply_properties(spec: AttributeEffectSpec, base_val: float, 
current_val: float, current_frame: int) -> void:
	var effect: AttributeEffect = spec.get_effect()
	spec._last_apply_frame = current_frame
	spec._apply_count += 1
	spec._last_value = effect.get_modified_value(self, spec)
	spec._last_set_value = effect.apply_calculator(base_val, current_val, spec._last_value)


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


## Returns true if [member effects_process_function] is set to anything other than 
## [enum ProcessFunction.NONE], false otherwise.
func _is_processing_enabled() -> bool:
	return effects_process_function != ProcessFunction.NONE


func _to_string() -> String:
	return "Attribute(id:%s)" % id
