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

## Helper function currently for [method Time.get_ticks_usec], created so that
## it can be swapped to other time units if deemed necessary.
static func _get_ticks() -> int:
	return Time.get_ticks_usec()


## Converts [param ticks] to secounds based.
static func _ticks_to_second(ticks: int) -> float:
	return ticks / 1_000_000.0


## Converts [param seconds] to ticks.
static func _seconds_to_tick(seconds: int) -> float:
	return seconds * 1_000_000.0


## Which _process function is used to execute effects.
enum ProcessFunction {
	## [method Node._process] is used.
	PROCESS = 0,
	## [method Node._physics_process] is used.
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
	## Effect was not added because it has a duration and it's initial duration was <= 0.0
	INVALID_DURATION = 5,
	## Effect is instant & can't be "added", but only applied.
	INSTANT_CANT_ADD = 6,
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
			_update_current_value()
		
		update_configuration_warnings()

@export_group("Effects")

## Which [ProcessFunction] is used when processing [AttributeEffect]s.
@export var effects_process_function: ProcessFunction = ProcessFunction.PROCESS:
	set(_value):
		effects_process_function = _value
		if !Engine.is_editor_hint():
			_update_processing()

## Array of all [AttributeEffect]s.
@export var _default_effects: Array[AttributeEffect] = []:
	set(value):
		_default_effects = value
		update_configuration_warnings()

## The [AttributeContainer] this attribute belongs to stored as a [WeakRef] for
## circular reference safety.
var _container: WeakRef

## Cluster of all added [AttributeEffectSpec]s.
var _specs: AttributeEffectSpecCluster = AttributeEffectSpecCluster.new()

## Dictionary of in the format of [code]{[member AttributeEffect.id] : int}[/code] count of all 
## applied [AttributeEffectSpec]s with that effect.
var _effect_counts: Dictionary = {}

## The internal current value
var _current_value: float:
	set(value):
		var prev_current_value: float = _current_value
		_current_value = _validate_current_value(value)
		if _current_value_initiated && _current_value != prev_current_value:
			current_value_changed.emit(prev_current_value)
			_current_value_changed(prev_current_value)
		update_configuration_warnings()

var _current_value_initiated: bool = false

## A lock mechanism to ensure code ran from signals emitted from this attribute does not
## attempt any unsafe changes that would break the logic & predictability of effects.
var _locked: bool = false

## For use in [method __process] ONLY. Per testing, it is more efficient to use
## a global dictionary than create a new one every frame.
var __process_to_remove: Dictionary = {}

## For use in [method __process] ONLY. Per testing, it is more efficient to use
## a global array than create a new one every frame.
var __process_emit_applied: Array[AttributeEffectSpec] = []

var _history: AttributeHistory

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	assert(get_parent() is AttributeContainer, "parent not of type AttributeContainer")
	_container = weakref(get_parent() as AttributeContainer)


func _ready() -> void:
	_current_value = _base_value
	_current_value_initiated = true
	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)
	else:
		_update_processing()
	
	# Find & set history
	for child: Node in get_children():
		if child is AttributeHistory:
			_history = child
			break
	
	## TODO initial effects


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_container = null


func _process(delta: float) -> void:
	__process()


func _physics_process(delta: float) -> void:
	__process()


## The heart & soul of Attribute, responsible for processing & applying [AttriubteEffectSpec]s.
## NOT meant to be overridden at all.
func __process() -> void:
	assert(!_locked, "attribute is locked")
	# Lock
	_locked = true
	
	# Store the current ticks in msec
	var current_tick: int = _get_ticks()
	
	# Keep track if a temp spec was removed so we can update current value later on
	var temp_spec_removed: bool = false
	
	# New base value for permanent effects
	var new_base_value: float = _base_value
	
	# Iterate all specs
	for index: int in _specs.iterate_indexes_reverse():
		# Store our most used objects as vars for cleaner code
		var spec: AttributeEffectSpec = _specs.get_at_index(index)
		# Not as efficient to store this here but the code is 10x cleaner
		var effect: AttributeEffect = spec.get_effect()
		
		# Skip if it was already processed this tick
		if spec._tick_last_processed == current_tick:
			print("SKIP: spec._tick_last_processed == current_tick, spec: %s" % spec)
			continue
		
		# Check if can process
		if !_test_process_conditions(spec):
			spec._is_processing = false
			continue
		
		# Get the amount of time since last process
		var seconds_since_last_process: float = _ticks_to_second(
		spec.get_ticks_since_last_process(current_tick))
		
		# Flag used to mark if the spec should be applied this frame
		var apply: bool = false
		
		# Mark as processing
		spec._is_processing = true
		spec._tick_last_processed = current_tick
		
		# Duration Calculations
		if effect.has_duration():
			spec.remaining_duration -= seconds_since_last_process
			if spec.remaining_duration <= 0.0: # Expired
				# Spec is expired at this point
				spec._expired = true
				# Add it to be removed at the end of this function
				__process_to_remove[index] = spec
				# Set current value to update if this is a temporary spec that expired
				if effect.is_temporary():
					temp_spec_removed = true
				# Set to apply if effect is apply on expire
				if effect.is_apply_on_expire():
					apply = true
		
		# Flag if period should be reset
		var reset_period: bool = false
		
		# Period Calculations
		if effect.has_period():
			spec.remaining_period -= seconds_since_last_process
			if spec.remaining_period <= 0.0:
				if !spec._expired: # Not expired, set to apply & mark period to reset
					apply = true
					reset_period = true
				elif effect.is_apply_on_expire_if_period_is_zero():
					# Set to apply since period is <=0 & it's expired
					apply = true
		
		# Apply; also resets the period in _apply_permanent_spec(...), and adds it to the remove 
		# and/or emit dictionary/array
		if apply:
			var applied: bool = _apply_permanent_spec(spec, index, current_tick, new_base_value, 
			__process_to_remove, __process_emit_applied, true)
			if applied:
				new_base_value = spec._last_set_value
	
	var base_value_updated: bool = _base_value != new_base_value
	# Update base value if changed
	if base_value_updated:
		_base_value = new_base_value
	# Update current value if base value changed or if a temp spec was removed
	# Unfortunately this has to be done seperately as we can't always predict temporary
	# specs expiring (due to effect modifiers, external logic, etc)
	if base_value_updated || temp_spec_removed:
		_update_current_value()

	# Emit applied signals
	if !__process_emit_applied.is_empty():
		for spec: AttributeEffectSpec in __process_emit_applied:
			effect_applied.emit(spec)
		__process_emit_applied.clear()
	
	# Remove specs that have expired or reached application limit
	if !__process_to_remove.is_empty():
		for index: int in __process_to_remove:
			var spec: AttributeEffectSpec = __process_to_remove[index]
			_remove_spec_at_index(spec, index, false)
		__process_to_remove.clear()
		_specs.update_reversed_range()
	
	# Unlock
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
	
	var has_history: bool = false
	for child: Node in get_children():
		if child is AttributeHistory:
			if has_history:
				warnings.append("Multiple AttributeHistory children detected")
				break
			else:
				has_history = true
	
	return warnings


## Returns the [AttributeContainer] this [Attribute] belongs to, null if there
## is no container (which shouldn't happen with proper [Node] management).
func get_container() -> AttributeContainer:
	return _container.get_ref() as AttributeContainer


## Returns true if this attribute has an [AttributeHistory] child monitoring it,
## or false if not.
func has_history() -> bool:
	return _history != null


## Returns the [AttributeHistory] of this attribute, or null if one does not exist.
func get_history() -> AttributeHistory:
	return _history


## Returns the base value of this attribute.
func get_base_value() -> float:
	return _base_value


## Manually sets the base value, also updating the current value.
func set_base_value(new_base_value: float) -> void:
	if _base_value != new_base_value:
		_base_value = new_base_value
		_update_current_value()


## Returns the current value, which is the [member base_value] affected by
## all [AttributeEffect]s of type [enum AttributeEffect.Type.TEMPORARY]
func get_current_value() -> float:
	return _current_value


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


## Sets [member AttributeEffectSpec._last_value] and [member AttributeEffectSpec._last_set_value]
## of [param spec] based on [param base_value] and [param current_value]. For use when applying
## an effect.
func _update_apply_values(spec: AttributeEffectSpec, base_value: float, current_value: float) -> void:
	spec._last_value = spec.get_effect().get_modified_value(self, spec)
	spec._last_set_value = spec.get_effect().apply_calculator(base_value, current_value, spec._last_value)


## Updates the value returned by [method get_current_value] by re-applying all
## [AttributeEffect]s of type [enum AttributeEffect.Type.TEMPORARY].
func _update_current_value() -> void:
	var new_current_value: float = calculate_current_value()
	
	if _current_value != new_current_value:
		_current_value = new_current_value


## Executes all active temporary [AttributeEffectSpec]s on the current [method get_base_value]
## and returns the calculated current value. May not reflect [method get_current_value] if this
## is called in the middle of processing.
func calculate_current_value() -> float:
	var current_value: float = _base_value
	for index: int in _specs._temp_specs.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = _specs._temp_specs.get_at_index(index)
		if !spec._expired:
			var spec_value: float = spec.get_effect().get_modified_value(self, spec)
			current_value = spec.get_effect().apply_calculator(_base_value, current_value, spec._last_value)
	
	return current_value


## Internal function that has a lot of parameters because I don't want to copy and
## paste code in __process and add_specs. Basically this bad boy just runs the apply
## logic for the spec and returns true if applied, false if not. Doesn't change anything
## except on the spec.
func _apply_permanent_spec(spec: AttributeEffectSpec, index: int, current_tick: int, 
base_value: float, to_remove: Dictionary, to_emit_applied: Array[AttributeEffectSpec],
 reset_period: bool) -> bool:
	if !_test_apply_conditions(spec):
		return false
	spec._apply_count += 1
	spec._tick_last_applied = current_tick
	
	# new_base_value provided twice as TEMPORARY effects have not yet been
	# applied to the base value
	_update_apply_values(spec, base_value, base_value)
	
	# Log to history
	if has_history() && spec.get_effect().should_log_history():
		_history._add_to_history(spec)
	
	spec._run_callbacks(AttributeEffectCallback._Function.APPLIED, self)
	# Remove if it hit apply limit
	if spec.hit_apply_limit():
		to_remove[index] = spec
	# Mark for emitting signal later on
	if spec.get_effect().should_emit_applied_signal():
		to_emit_applied.append(spec)

	# Reset period after applying
	if reset_period:
		# Add (instead of reset) period for more accuracy when dealing w/ low frame rate
		spec.remaining_period += spec.get_effect().get_modified_period(self, spec)
	return true


## Returns true if the [param effect] is present and has one or more [AttributeEffectSpec]s
## applied to this [Attribute], false if not.
func has_effect(effect: AttributeEffect) -> bool:
	assert(effect != null, "effect is null")
	return _effect_counts.has(effect)


## Returns the total amount of [AttributeEffectSpec]s whose effect is [param effect].
## Highly efficient as it simply uses [method Dictionary.get] on an internally managed dictionary.
func get_effect_count(effect: AttributeEffect) -> int:
	assert(effect != null, "effect is null")
	return _effect_counts.get(effect, 0)


## Returns true if [param spec] is currently applied to this [Attribute], false if not.
func has_spec(spec: AttributeEffectSpec) -> bool:
	assert(spec != null, "spec is null")
	return _specs.has(spec)


## Searches through all active [AttributeEffectSpec]s and returns a new [Array] of all specs
## whose [method AttributEffectSpec.get_effect] equals [param effect].
func find_specs(effect: AttributeEffect) -> Array[AttributeEffectSpec]:
	var specs: Array[AttributeEffectSpec] = []
	for index: int in _specs.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = _specs.get_at_index(index)
		if spec.get_effect() == effect:
			specs.append(spec)
			continue
	return specs


## Searches through all active [AttributeEffectSpec]s and returns the first spec
## whose [method AttributEffectSpec.get_effect] equals [param effect]. Returns null
## if there is no spec of [param effect]. Useful when you know that the [param effect]'s
## stack mode is COMBINE, DENY, or DENY_ERROR as in those cases there can only 
## be one instance of the effect.
func find_first_spec(effect: AttributeEffect) -> AttributeEffectSpec:
	for index: int in _specs.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = _specs.get_at_index(index)
		if spec.get_effect() == effect:
			return spec
	return null


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


## Adds (& possibly applies) of each of the [param specs]. Can result in immediate
## changes to the base value & current value, depending on the provided [param specs].
## [br][b]There are multiple considerations when calling this function:[/b]
## [br]  - If a spec has stack_mode COMBINE, it is stacked to the existing spec of the same 
## [AttributeEffect], and thus not added. The new stack count is the existing's + the new spec's
## stack count.
## [br]  - If a spec is PERMANENT, it is applied when it is added unless the spec has an initial period.
## [br]  - If TEMPORARY, it is not applied, however the current_value is updated instantly.
## [br]  - If INSTANT, it is not added, only applied.
## [br]  - Specs are initialized unless already initialized or are stacked instead of added.
func add_specs(specs: Array[AttributeEffectSpec]) -> void:
	assert(!specs.is_empty(), "specs is empty")
	assert(!specs.has(null), "specs has null element")
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	
	_locked = true
	
	var perm_specs_to_apply: AttributeEffectSpecArray = \
	AttributeEffectSpecArray.new(AttributeEffect.Type.PERMANENT)
	
	var update_current: bool = false
	var current_tick: int = _get_ticks()
	
	# Initialize specs
	# Sort specs into arrays ordered by priority
	# Set permanent specs to apply if they should
	for spec: AttributeEffectSpec in specs:
		assert(spec != null, "specs has null element")
		assert(!spec.is_added(), "spec (%s) already added" % spec)
		
		# Throw error if spec's effect exists & has StackMode.DENY_ERROR
		assert(spec.get_effect().stack_mode != AttributeEffect.StackMode.DENY_ERROR or \
		!has_effect(spec.get_effect()), 
		"spec (%s)'s effect stack_mode == DENY_ERROR but stacking was attempted" % spec)
		
		# Effect is instant, ignore other logic.
		if spec.get_effect().is_instant():
			spec._last_add_result = AddEffectResult.INSTANT_CANT_ADD
			perm_specs_to_apply.add(spec, false)
			continue
		
		# Do not stack if DENY or DENY_ERROR & effect already exists
		if (spec.get_effect().stack_mode == AttributeEffect.StackMode.DENY or \
		spec.get_effect().stack_mode == AttributeEffect.StackMode.DENY_ERROR) and \
		has_effect(spec.get_effect()):
			spec._last_add_result = AddEffectResult.STACK_DENIED
			continue
		
		# Check add conditions
		if !_test_add_conditions(spec):
			continue
		
		# Handle COMBINE stacking (only if a spec of the same effect already exists)
		if spec.get_effect().stack_mode == AttributeEffect.StackMode.COMBINE \
		and has_effect(spec.get_effect()):
			var existing: Array[AttributeEffectSpec] = find_specs(spec.get_effect())
			assert(existing.size() == 1, ("effect (%s) has stack_mode COMBINE but " + \
			"> or < 1 specs exists on this attribute (%s)") % [spec.get_effect(), self])
			
			spec._last_add_result = AddEffectResult.STACKED
			existing[0]._add_to_stack(self, spec.get_stack_count())
			# Update current value if a temporary spec is added
			if spec.get_effect().is_temporary():
				update_current = true
			continue
		
		# Initialize if not done so
		if !spec.is_initialized():
			spec._initialize(self)
		
		# Don't add it if it has remaining duration of <= 0.0
		if spec.get_effect().has_duration() && spec.remaining_duration <= 0.0:
			spec._last_add_result = AddEffectResult.INVALID_DURATION
			continue
		
		# Update current value if a temporary spec is added
		if spec.get_effect().is_temporary():
			update_current = true
		
		# Run pre_add callbacks
		spec._run_callbacks(AttributeEffectCallback._Function.PRE_ADD, self)
		
		# At this point it can be added
		spec._is_added = true
		spec._last_add_result = AddEffectResult.ADDED
		spec._tick_added_on = current_tick
		
		# Add to array
		_specs.add(spec, false)
		
		# Add to _effect_counts
		var new_count: int = _effect_counts.get(spec.get_effect(), 0) + 1
		_effect_counts[spec.get_effect()] = new_count
		
		# Run callbacks & emit signal
		spec._run_callbacks(AttributeEffectCallback._Function.ADDED, self)
		if spec.get_effect().should_emit_added_signal():
			effect_added.emit(spec)
		
		# Mark it to apply if initial period <= 0.0
		if spec.get_effect().has_period() && spec.remaining_period <= 0.0:
			perm_specs_to_apply.add(spec, false)
	
	# Update specs range for iterating
	_specs.update_reversed_range()
	
	var to_remove: Dictionary = {}
	var to_emit_applied: Array[AttributeEffectSpec] = []

	# Apply all permanent specs that should apply
	if !perm_specs_to_apply.is_empty():
		var new_base_value: float = _base_value
		# Update range before iterataing
		perm_specs_to_apply.update_reversed_range()
		
		# Iterate specs & apply them
		for index: int in perm_specs_to_apply.iterate_indexes_reverse():
			var spec: AttributeEffectSpec = perm_specs_to_apply.get_at_index(index)
			var applied: bool = _apply_permanent_spec(spec, index, current_tick, new_base_value, 
			to_remove, to_emit_applied, spec.get_effect().has_period())
			if applied: # Update base value if applied
				new_base_value = spec._last_set_value
		
		# Update base value if changed
		if _base_value != new_base_value:
			_base_value = new_base_value
			# If base value changed, update current value next
			update_current = true
	
	# Update current value if neccessary
	if update_current:
		_update_current_value()
	
	# Emit applied signal for applied specs
	if !to_emit_applied.is_empty():
		for spec: AttributeEffectSpec in to_emit_applied:
			effect_applied.emit(spec)
	
	# Remove specs that have hit their apply limit
	if !to_remove.is_empty():
		for index: int in to_remove:
			var spec: AttributeEffectSpec = to_remove[index] as AttributeEffectSpec
			_remove_spec_at_index(spec, index, false)
		_specs.update_reversed_range()
	
	_locked = false


## Removes all [AttributeEffectSpec]s whose effect equals [param effect]. Returns true
## if 1 or more specs were removed, false if none were removed.
func remove_effect(effect: AttributeEffect) -> bool:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	_locked = true
	
	var removed: bool = _remove_based_on_predicate( 
		func(_effect) -> bool:
			return _effect == effect
	)
	
	if effect.type == AttributeEffect.Type.TEMPORARY && removed:
		_update_current_value()
	
	_locked = false
	return removed


## Removes all [AttributeEffectSpec]s whose effect is present in [param effects]. 
## Returns true if 1 or more specs were removed, false if none were removed.
func remove_effects(effects: Array[AttributeEffect]) -> bool:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	assert(!effects.has(null), "effects has null element")
	_locked = true
	var removed: bool = _remove_based_on_predicate(
		func (spec: AttributeEffectSpec) -> bool:
			return effects.has(spec.get_effect())
	)
	_locked = false
	return removed


## Removes the [param spec], returning true if removed, false if not.
func remove_spec(spec: AttributeEffectSpec) -> bool:
	for index: int in _specs.iterate_indexes_reverse():
		var other_spec: AttributeEffectSpec = _specs.get_at_index(index)
		if spec == other_spec:
			_remove_spec_at_index(other_spec, index, true)
			return true
	return false


## Removes all [param specs], returning true if 1 or more were removed, false if 
## none were removed.
func remove_specs(specs: Array[AttributeEffectSpec]) -> bool:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	assert(!specs.has(null), "specs has null element")
	_locked = true
	var removed: bool = _remove_based_on_predicate(
		func (spec: AttributeEffectSpec) -> bool:
			return specs.has(spec)
	)
	_locked = false
	return removed


## Manually removes all [AttributeEffectSpec]s, or instantly removes them if
## [method is_in_process_loop] returns false.
func remove_all_effects() -> void:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	_locked = true
	
	var removed_specs: Array[AttributeEffectSpec] = []
	for index: int in _specs.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = _specs.get_at_index(index)
		_pre_remove_spec(spec)
		removed_specs.append(spec)
	_specs.clear()
	_effect_counts.clear()
	
	for spec: AttributeEffectSpec in removed_specs:
		_post_remove_spec(spec)
	
	_current_value = _base_value
	_locked = false


func _remove_based_on_predicate(spec_predicate: Callable) -> bool:
	var removed: bool = false
	for index: int in _specs.iterate_indexes_reverse():
		var spec: AttributeEffectSpec = _specs.get_at_index(index)
		if spec_predicate.call(spec):
			_remove_spec_at_index(spec, index, false)
			removed = true
	
	if removed:
		_specs.update_reversed_range()
	return removed


func _remove_from_effect_counts(spec: AttributeEffectSpec) -> void:
	if _effect_counts.has(spec.get_effect()):
		var new_count: int = _effect_counts[spec.get_effect()] - 1
		if new_count <= 0:
			_effect_counts.erase(spec.get_effect())
		else:
			_effect_counts[spec.get_effect()] = new_count


func _remove_spec_at_index(spec: AttributeEffectSpec, index: int, 
update_reverse_range: bool) -> void:
	_pre_remove_spec(spec)
	_specs.remove_at(index, update_reverse_range)
	_remove_from_effect_counts(spec)
	_post_remove_spec(spec)


func _pre_remove_spec(spec: AttributeEffectSpec) -> void:
	spec._run_callbacks(AttributeEffectCallback._Function.PRE_REMOVE, self)
	spec._is_added = false
	spec._is_processing = false


func _post_remove_spec(spec: AttributeEffectSpec) -> void:
	if spec.get_effect().should_emit_removed_signal():
		effect_removed.emit(spec)
	spec._run_callbacks(AttributeEffectCallback._Function.REMOVED, self)


func _test_add_conditions(spec: AttributeEffectSpec) -> bool:
	if _test_conditions_and_emit_failed(spec, spec._can_add, effect_add_blocked):
		return true
	spec._last_add_result = AddEffectResult.BLOCKED_BY_CONDITION
	return false


func _test_apply_conditions(spec: AttributeEffectSpec) -> bool:
	return _test_conditions_and_emit_failed(spec, spec._can_apply, effect_apply_blocked)


func _test_process_conditions(spec: AttributeEffectSpec) -> bool:
	return _test_conditions_and_emit_failed(spec, spec._can_process, Signal())


func _test_conditions_and_emit_failed(spec: AttributeEffectSpec, callable: Callable, 
_signal: Signal) -> bool:
	spec._last_blocked_by = callable.call(self)
	if spec._last_blocked_by != null:
		if spec._last_blocked_by.emit_blocked_signal && !_signal.is_null():
			_signal.emit(spec)
		return false
	return true


func _update_processing() -> void:
	set_process(effects_process_function == ProcessFunction.PROCESS)
	set_physics_process(effects_process_function == ProcessFunction.PHYSICS_PROCESS)


func _to_string() -> String:
	return "Attribute(id:%s)" % id
