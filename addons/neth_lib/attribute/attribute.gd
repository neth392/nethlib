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

## Internal time unit used to appropriately set it to the [PauseTracker].
const INTERNAL_TIME_UNIT: TimeUtil.TimeUnit = TimeUtil.TimeUnit.MICROSECONDS

## Helper function currently for [method Time.get_ticks_usec], created so that
## it can be swapped to other time units if deemed necessary.
static func _get_ticks() -> int:
	return Time.get_ticks_usec()


static func _ticks_to_seconds(ticks: int) -> float:
	return ticks / 1_000_000.0


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
	## No attempt to add the effect to an [Attribute] was ever made.
	NEVER_ADDED = 0,
	## Successfully added.
	ADDED = 1,
	## Added to an existing [AttributeEffectSpec] via stacking.
	STACKED = 2,
	## Blocked by an [AttributeEffectCondition], retrieve it via
	## [method get_last_blocked_by].
	BLOCKED_BY_CONDITION = 3,
	## Blocked by a condition of a BLOCKER [AttributeEffect].
	BLOCKED_BY_BLOCKER = 4,
	## Another spec of the same effect is already present on the [Attribute] and 
	## stack_mode is set to DENY.
	STACK_DENIED = 5,
	## Not added because its initial duration was <= 0.0
	INVALID_DURATION = 6,
	## Effect is instant & can't be "added", but only applied. This does not indicate
	## if it was applied or not.
	INSTANT_CANT_ADD = 7,
}

## Determines how to sort [AttributeEffect]s who have the same priority.
enum SamePrioritySortingMethod {
	## Effects that are added are sorted [b]after[/b] effects of the same priority 
	## that previously existed.
	OLDER_FIRST,
	## Effects that are added are sorted [b]before[/b] effects of the same priority
	## that previously existed.
	NEWER_FIRST,
}

###################
## Value Signals ##
###################

## Emitted when the value returned by [method get_current_value] changes.
signal current_value_changed(prev_current_value: float)

## Emitted when [member _base_value] changes. Similar to [signal base_value_event]
## but ONLY emits if the base value changed, and does not include the cause. [param spec]
## is the [AttributeEffectSpec] that caused the change, null if the change was done manually
## via [method set_base_value].
signal base_value_changed(prev_base_value: float, spec: AttributeEffectSpec)

####################
## Effect Signals ##
####################

## Emitted after the [param spec] was added to this [Attribute]. If the
## relative [AttributeEffect] is of [enum AttributEffect.DurationType.INSTANT] then
## [method has_effect] will return false when called with [param spec].
signal effect_added(spec: AttributeEffectSpec)

## TODO
signal effect_applied(spec: AttributeEffectSpec)

## Emitted when the [param spec] was removed. To determine if it was manual
## or due to expiration, see [method AttributeEffectSpec.expired].
signal effect_removed(spec: AttributeEffectSpec)

## Emitted when the [param spec] had its stack count changed.
signal effect_stack_count_changed(spec: AttributeEffectSpec, previous_stack_count: int)

## Emitted after [param blocked] was blocked from being added to
## this [Attribute] by an [AttributeEffectCondition], accessible via 
## [method AttributeEffectSpec.get_last_blocked_by]. [param blocked_by] is the owner
## of that condition, and could (but not always in the case of BLOCKER effects) be the same
## as [param blocked].
signal effect_add_blocked(blocked: AttributeEffectSpec, blocked_by: AttributeEffectSpec)

## Emitted after [param blocked] was blocked from being applied to
## this [Attribute] by an [AttributeEffectCondition], accessible via 
## [method AttributeEffectSpec.get_last_blocked_by]. [param blocked_by] is the owner
## of that condition, and could (but not always in the case of BLOCKER effects) be the same
## as [param blocked].
signal effect_apply_blocked(blocked: AttributeEffectSpec, blocked_by: AttributeEffectSpec)


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
			_notify_base_value_changed(prev_base_value)
		update_configuration_warnings()

@export_group("Effects")

## Whether or not [AttributeEffectSpec]s should be allowed. If effects are not allowed,
## processing is automatically disabled.
@export var allow_effects: bool = true:
	set(value):
		allow_effects = value
		if !allow_effects:
			effects_process_function = ProcessFunction.NONE
			if !Engine.is_editor_hint():
				remove_all_specs()
		_update_processing()
		notify_property_list_changed()

## Which [ProcessFunction] is used when processing [AttributeEffect]s.
@export var effects_process_function: ProcessFunction = ProcessFunction.PROCESS:
	set(_value):
		effects_process_function = _value
		if !Engine.is_editor_hint():
			_update_processing()

## Determines how to sort effects who share the same priority.
@export var same_priority_sorting_method: SamePrioritySortingMethod:
	set(value):
		assert(Engine.is_editor_hint() || !is_node_ready(), "same_priority_sorting_method " + \
		"can not be changed at runtime.")
		same_priority_sorting_method = value

## If true, default effects are added via using [method Callable.call_deferred]
## on [method add_effects], which allows time to connect to this attribute's
## signals to be notified of the additions.
@export var defer_default_effects: bool = false

## Array of all [AttributeEffect]s.
@export var _default_effects: Array[AttributeEffect] = []:
	set(value):
		_default_effects = value
		update_configuration_warnings()

@export_group("Components")

## The [PauseTracker] used by this [Attribute] to track pausing. Usually this
## can be left untouched. Must NOT be null.
@export var pause_tracker: PauseTracker

## The [AttributeContainer] this attribute belongs to stored as a [WeakRef] for
## circular reference safety.
var _container: WeakRef

## Cluster of all added [AttributeEffectSpec]s.
var _specs: AttributeEffectSpecArray 

## Internal storage of [member _specs]'s size for disabling processing when no effects
## are active, for performance gains.
var _has_specs: bool = false:
	set(value):
		var prev: bool = _has_specs
		_has_specs = value
		_update_processing()

## Dictionary of in the format of [code]{[member AttributeEffect.id] : int}[/code] count of all 
## applied [AttributeEffectSpec]s with that effect.
var _effect_counts: Dictionary = {}

## The internal current value.
## [br]WARNING: Do not set this directly, it is automatically calculated.
var _current_value: float:
	set(value):
		var prev_current_value: float = _current_value
		_current_value = value
		if _current_value != prev_current_value:
			_notify_current_value_changed(prev_current_value)
		update_configuration_warnings()

var _current_value_initiated: bool = false

## A lock mechanism to ensure code ran from signals emitted from this attribute does not
## attempt any unsafe changes that would break the logic & predictability of effects.
var _locked: bool = false

## For use in [method __process] ONLY. Per testing, it is more efficient to use
## a global dictionary than create a new one every frame.
var __process_to_remove: Dictionary = {}

var _history: AttributeHistory

## The tick the scene tree was paused at.
var _paused_at_tick: int = -1

## Internal flag to prevent further effects from applying.
var _stop_applying: bool = false

## Internal flag to mark [method stop_applying] as a valid call or not.
var _can_stop_applying: bool = false

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	assert(get_parent() is AttributeContainer, "parent not of type AttributeContainer")
	_container = weakref(get_parent() as AttributeContainer)


func _ready() -> void:
	_update_processing()
	# Escape if editor
	if Engine.is_editor_hint():
		return
	
	_current_value = _validate_current_value(_base_value)
	_current_value_initiated = true
	
	# Find & set history
	for child: Node in get_children():
		if child is AttributeHistory:
			_history = child
			break
	
	# Pause Tracker
	pause_tracker.time_unit = INTERNAL_TIME_UNIT
	pause_tracker.unpaused.connect(_on_unpaused)
	
	# Handle default effects
	if allow_effects && !_default_effects.is_empty():
		if defer_default_effects:
			add_effects.call_deferred(_default_effects)
		else:
			add_effects(_default_effects)


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_container = null


## Handle pausing
func _on_unpaused(time_paused: float) -> void:
	var paused_at: int = int(_get_ticks() - time_paused)
	var unpaused_at: int = _get_ticks()
	for spec: AttributeEffectSpec in _specs.iterate():
		# If added during the pause, set process time to unpause time
		if spec._tick_added_on >= paused_at:
			spec._tick_last_processed = unpaused_at
		else: # If added before pause, add time puased to process time
			spec._tick_last_processed += time_paused


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
	_can_stop_applying = true
	
	# Iterate all specs
	var index: int = -1
	for spec: AttributeEffectSpec in _specs.iterate():
		index += 1
		
		# Store the current tick
		var current_tick: int = _get_ticks()
		
		# Get the amount of time since last process
		var seconds_since_last_process: float = _ticks_to_seconds(
		current_tick - spec.get_tick_last_processed())
		
		# Add to active duration
		spec._active_duration += seconds_since_last_process
		
		# Flag used to mark if the spec should be applied this frame
		var apply: bool = false
		
		# Mark as processing
		spec._tick_last_processed = current_tick
		
		# Duration Calculations
		if spec.get_effect().has_duration():
			spec.remaining_duration -= seconds_since_last_process
			if spec.remaining_duration <= 0.0: # Expired
				# Spec is expired at this point
				spec._expired = true
				# Remove it from effect counts so that it doesn't appear in has_effect
				_remove_from_effect_counts(spec)
				# Add it to be removed at the end of this function
				__process_to_remove[index] = spec
				# Update current value if this expired
				if spec.get_effect().is_temporary():
					_update_current_value()
				# Set to apply if effect is apply on expire
				if spec.get_effect().is_apply_on_expire():
					apply = true
		
		# Flag if period should be reset
		var reset_period: bool = false
		
		# Period Calculations
		if spec.get_effect().has_period():
			spec.remaining_period -= seconds_since_last_process
			if spec.remaining_period <= 0.0:
				if !spec._expired: # Not expired, set to apply & mark period to reset
					apply = true
					# Period should be reset as this spec is not expired
					reset_period = true
				elif spec.get_effect().is_apply_on_expire_if_period_is_zero():
					# Set to apply since period is <=0 & it's expired
					apply = true
		
		# stop_applying() was called
		if _stop_applying:
			# Reset the period here (that is usually done below)
			if reset_period:
				_reset_period(spec)
			continue
		
		# Check if it should apply
		if apply:
			_apply_permanent_spec(spec, current_tick, __process_to_remove, index)
		
		# Reset the period
		if reset_period:
			_reset_period(spec)
	
	# Remove specs that have expired or reached application limit
	if !__process_to_remove.is_empty():
		# Keep track of removed count to adjust next index
		var removed_count: int = 0
		for spec_index: int in __process_to_remove:
			_remove_spec_at_index(__process_to_remove[spec_index], spec_index - removed_count, false)
			removed_count += 1
		__process_to_remove.clear()
	
	_can_stop_applying = false
	_stop_applying = false
	
	# Unlock
	_locked = false


func _validate_property(property: Dictionary) -> void:
	if property.name == "effects_process_function":
		if !allow_effects:
			property.usage = PROPERTY_USAGE_STORAGE
		return
	if property.name == "_default_effects":
		if !allow_effects:
			property.usage = PROPERTY_USAGE_STORAGE
		return


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


## Can safely be called during the applying of [AttributeEffectSpec]s to prevent further
## specs from applying this frame. Other effects will still have duration & period processing
## conducted, but effects will NOT apply at all. This was designed to be used in an example
## case where an entity has received a killing blow which means subsequent effects should stop being
## applied. It is up to the game creator to remove the remaining effects to ensure they
## are not processed next frame, as this method does not modify the next frame at all.
## [br]NOTE: Will throw an error (via assertion) if this is called when effects 
## are not being applied. 
func stop_applying() -> void:
	assert(_can_stop_applying, "no effects are currently being applied, invalid method call")
	_stop_applying = true


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
		var prev_base_value: float = _base_value
		_base_value = new_base_value
		base_value_changed.emit(prev_base_value, null)
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


## Called in the setter of [member _base_value] after the value has been changed, used
## to notify extending classes of the change.
func _notify_base_value_changed(prev_base_value: float) -> void:
	pass


## Called in the setter of [member _current_value] after the value has been changed, used
## to notify extending classes of the change.
func _notify_current_value_changed(prev_current_value: float) -> void:
	pass


## Updates the value returned by [method get_current_value] by re-applying all
## [AttributeEffect]s of type [enum AttributeEffect.Type.TEMPORARY].
func _update_current_value() -> void:
	var new_current_value: float = calculate_current_value()
	
	if _current_value != new_current_value:
		var prev_current_value: float = _current_value
		_current_value = new_current_value
		# TODO decide on where to add these signals
		current_value_changed.emit(prev_current_value)


## Executes all active temporary [AttributeEffectSpec]s on the current [method get_base_value]
## and returns the calculated current value. May not reflect [method get_current_value] if this
## is called in the middle of processing.
## [br][param _validate] is mostly for internal use, but if true the calculated value is ran through
## [method _validate_current_value] before being returned.
func calculate_current_value() -> float:
	var new_current_value: float = _base_value
	for spec: AttributeEffectSpec in _specs.iterate_temp():
		if spec.is_expired():
			continue
		spec._last_effect_value = _get_modified_value(spec)
		new_current_value = spec.get_effect().apply_calculator(_base_value, new_current_value, spec._last_effect_value)
	
	return _validate_current_value(new_current_value)


func _reset_period(spec: AttributeEffectSpec) -> void:
	# Add (instead of reset) period for more accuracy when dealing w/ low frame rate
	spec.remaining_period += _get_modified_period(spec)


## Returns a new [Array] (safe to mutate) of the current [AttributeEffectSpec]s.
## The specs themselves are NOT duplicated.
func get_specs() -> Array[AttributeEffectSpec]:
	return _specs._array.duplicate(false)


## Returns a new [Array] (safe to mutate) of all current [AttributeEffect]s.
## The effects themselves are NOT duplicated.
func get_effects() -> Array[AttributeEffect]:
	return _effect_counts.keys()


## Returns a new [Dictionary] (safe to mutate) of all current [AttributeEffect]s as keys,
## and the integer count of the amount of [AttributeEffectSpec]s of each effect as values.
## The effects themselves are NOT duplicated.
func get_effects_with_counts() -> Dictionary:
	return _effect_counts.duplicate(false)


## Returns true if the [param effect] is present and has one or more [AttributeEffectSpec]s
## applied to this [Attribute], false if not. Does not account for any specs that are
## expired & not yet removed (during the processing).
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
	for spec: AttributeEffectSpec in _specs.iterate():
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
	for spec: AttributeEffectSpec in _specs.iterate():
		if spec.get_effect() == effect:
			return spec
	return null


## Creates an [AttributeEffectSpec] from the [param effect] via [method AttriubteEffect.to_spec]
## and then calls [method add_specs]
func add_effect(effect: AttributeEffect) -> void:
	assert(allow_effects, "allow_effects is false")
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	add_effects([effect], false)


## Creates an [AttributeEffectSpec] from each of the [param effects] via 
## [method AttriubteEffect.to_spec] and then calls [method add_specs].
## [param sort_by_priority] determines what order the specified effects should be applied in (if
## any are to be applied instantly). If true, they are sorted by their [member AttributeEffect.priority],
## if false they are applied in the order of the specified [param effects] array.
func add_effects(effects: Array[AttributeEffect], sort_by_priority: bool = true) -> void:
	assert(allow_effects, "allow_effects is false")
	assert(!effects.has(null), "effects has null element")
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	var specs: Array[AttributeEffectSpec] = []
	for effect: AttributeEffect in effects:
		specs.append(effect.to_spec())
	add_specs(specs)


## Adds [param spec] to a new [Array], then calls [method add_specs]
func add_spec(spec: AttributeEffectSpec) -> void:
	assert(allow_effects, "allow_effects is false")
	assert(spec != null, "spec is null")
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	add_specs([spec], false)


## Adds (& possibly applies) of each of the [param specs]. Can result in immediate
## changes to the base value & current value, depending on the provided [param specs]. 
## [param sort_by_priority] determines what order the specified specs should be applied in (if
## any are to be applied instantly). If true, they are sorted by their [member AttributeEffect.priority],
## if false they are applied in the order of the specified [param specs] array.
## [br][b]There are multiple considerations when calling this function:[/b]
## [br]  - If a spec has stack_mode COMBINE, it is stacked to the existing spec of the same 
## [AttributeEffect], and thus not added. The new stack count is the existing's + the new spec's
## stack count.
## [br]  - If a spec is PERMANENT, it is applied when it is added unless the spec has an initial period.
## [br]  - If TEMPORARY, it is not applied, however the current_value is updated instantly.
## [br]  - If INSTANT, it is not added, only applied.
## [br]  - Specs are initialized unless already initialized or are stacked instead of added.
func add_specs(specs: Array[AttributeEffectSpec], sort_by_priority: bool = true) -> void:
	assert(allow_effects, "allow_effects is false")
	assert(!specs.is_empty(), "specs is empty")
	assert(!specs.has(null), "specs has null element")
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	
	_locked = true
	
	var perm_specs_to_apply: Dictionary = {}
	
	var update_current: bool = false
	var current_tick: int = _get_ticks()
	
	var specs_to_add: Array[AttributeEffectSpec] = specs
	if sort_by_priority:
		specs_to_add = specs.duplicate(false)
		specs_to_add.sort_custom(_specs._sort_new_before_other)
	
	# Initialize specs
	# Sort specs into arrays ordered by priority
	# Set permanent specs to apply if they should
	for spec: AttributeEffectSpec in specs_to_add:
		assert(spec != null, "specs has null element")
		assert(!spec.is_added(), "spec (%s) already added" % spec)
		
		# Throw error if spec's effect exists & has StackMode.DENY_ERROR
		assert(spec.get_effect().stack_mode != AttributeEffect.StackMode.DENY_ERROR or \
		!has_effect(spec.get_effect()), 
		"spec (%s)'s effect stack_mode == DENY_ERROR but stacking was attempted" % spec)
		
		# Effect is instant, ignore other logic.
		if spec.get_effect().is_instant():
			spec._last_add_result = AddEffectResult.INSTANT_CANT_ADD
			perm_specs_to_apply[spec] = -1
			continue
		
		# Do not stack if DENY or DENY_ERROR & effect already exists
		if (spec.get_effect().stack_mode == AttributeEffect.StackMode.DENY or \
		spec.get_effect().stack_mode == AttributeEffect.StackMode.DENY_ERROR) and \
		has_effect(spec.get_effect()):
			spec._last_add_result = AddEffectResult.STACK_DENIED
			continue
		
		# Check add conditions & blockers
		if !_test_add_conditions(spec):
			continue
		
		# Handle COMBINE stacking (only if a spec of the same effect already exists)
		if spec.get_effect().stack_mode == AttributeEffect.StackMode.COMBINE \
		and has_effect(spec.get_effect()):
			var existing: AttributeEffectSpec = find_first_spec(spec.get_effect())
			assert(existing != null, ("existing is null, but has_effect returned true " + \
			"for spec %s") % spec)
			spec._last_add_result = AddEffectResult.STACKED
			existing._add_to_stack(self, spec.get_stack_count())
			# Update current value if a temporary spec is added
			if spec.get_effect().is_temporary():
				update_current = true
			continue
		
		# Initialize if not done so
		if !spec.is_initialized():
			_initialize_spec(spec)
		
		# Don't add it if it has remaining duration of <= 0.0
		if spec.get_effect().has_duration() && spec.remaining_duration <= 0.0:
			spec._last_add_result = AddEffectResult.INVALID_DURATION
			continue
		
		# Update current value if a temporary spec is added
		if spec.get_effect().is_temporary():
			update_current = true
		
		# Run pre_add callbacks
		_run_callbacks(spec, AttributeEffectCallback._Function.PRE_ADD)
		
		# At this point it can be added
		spec._is_added = true
		spec._last_add_result = AddEffectResult.ADDED
		spec._tick_added_on = current_tick
		spec._tick_last_processed = current_tick
		
		# Add to array
		var index: int = _specs.add(spec)
		
		# Add to _effect_countsg
		var new_count: int = _effect_counts.get(spec.get_effect(), 0) + 1
		_effect_counts[spec.get_effect()] = new_count
		
		# Run callbacks & emit signal
		_run_callbacks(spec, AttributeEffectCallback._Function.ADDED)
		if spec.get_effect().should_emit_added_signal():
			effect_added.emit(spec)
		
		# Mark it to apply if initial period <= 0.0
		if spec.get_effect().has_period() && spec.remaining_period <= 0.0:
			perm_specs_to_apply[spec] = index
	
	var to_remove: Dictionary = {}
	var to_emit_applied: Array[AttributeEffectSpec] = []

	# Apply all permanent specs that should apply
	if !perm_specs_to_apply.is_empty():
		var new_base_value: float = _base_value
		
		# Iterate specs & apply them
		for spec: AttributeEffectSpec in perm_specs_to_apply:
			# Set pending value
			spec._pending_value = spec.get_effect().get_modified_value(self, spec)
			if _test_apply_conditions(spec):
				var index: int = perm_specs_to_apply[spec]
				
				spec._last_value = spec._pending_value
				
				# Clear pending value
				spec._pending_value = 0.0
				
				spec._last_set_value = spec.get_effect().apply_calculator(new_base_value, 
				_current_value, spec._last_value)
				## TODO FIX THIS CODE
				#_apply_permanent_spec(spec, index, current_tick, new_base_value, to_remove, 
				#to_emit_applied)
				# Update base value
				new_base_value = spec._last_set_value
			else:
				# Clear pending value
				spec._pending_value = 0.0
			
			# Reset period if there is one
			if spec.get_effect().has_period(): 
				_reset_period(spec)
		
		# Update base value if changed
		if _base_value != new_base_value:
			_base_value = new_base_value
			# If base value changed, update current value next
			update_current = true
	
	# Update current value if neccessary
	if update_current:
		_update_current_value()
	
	# Emit applied signal for applied specs
	for spec: AttributeEffectSpec in to_emit_applied:
		effect_applied.emit(spec)
	
	# Remove specs that have hit their apply limit
	if !to_remove.is_empty():
		var removed_count: int = 0
		for index: int in to_remove:
			## TODO FIX THIS CODE (should be FALSE as last param & removed from effect counts above)
			_remove_spec_at_index(to_remove[index], index - removed_count, true)
			removed_count += 1
	
	# Process if specs is not empty
	_has_specs = !_specs.is_empty()
	
	_locked = false


## Removes all [AttributeEffectSpec]s whose effect equals [param effect]. Returns true
## if 1 or more specs were removed, false if none were removed.
func remove_effect(effect: AttributeEffect) -> bool:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	_locked = true
	
	var removed: bool = false
	for index: int in _specs.iterate_reverse():
		var spec: AttributeEffectSpec = _specs._array[index]
		if spec.get_effect() == effect:
			_remove_spec_at_index(spec, index, true)
			removed = true
	
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
	
	var removed: bool = false
	var temporary_removed: bool = false
	for index: int in _specs.iterate_reverse():
		var spec: AttributeEffectSpec = _specs._array[index]
		if effects.has(spec.get_effect()):
			_remove_spec_at_index(spec, index, true)
			removed = true
			if spec.get_effect().is_temporary():
				temporary_removed = true
	
	if temporary_removed:
		_update_current_value()
	
	_locked = false
	return removed


## Removes the [param spec], returning true if removed, false if not.
func remove_spec(spec: AttributeEffectSpec) -> bool:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	if !has_spec(spec):
		return false
	_locked = true
	_pre_remove_spec(spec)
	_specs.erase(spec)
	_has_specs = !_specs.is_empty()
	_remove_from_effect_counts(spec)
	_post_remove_spec(spec)
	if spec.get_effect().is_temporary():
		_update_current_value()
	_locked = false
	return true


## Removes all [param specs], returning true if 1 or more were removed, false if 
## none were removed.
func remove_specs(specs: Array[AttributeEffectSpec]) -> bool:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	_locked = true
	var removed: bool = false
	var temporary_removed: bool = false
	for index: int in _specs.iterate_reverse():
		var spec: AttributeEffectSpec = _specs._array[index]
		if specs.has(specs):
			_remove_spec_at_index(spec, index, true)
			removed = true
			if spec.get_effect().is_temporary():
				temporary_removed = true
	
	if temporary_removed:
		_update_current_value()
	_locked = false
	return removed


## Manually removes all [AttributeEffectSpec]s, or instantly removes them if
## [method is_in_process_loop] returns false.
func remove_all_specs() -> void:
	assert(!_locked, "Attribute is locked, use call_deferred on this function")
	_locked = true
	
	var removed_specs: Array[AttributeEffectSpec] = _specs._array.duplicate(false)
	for spec: AttributeEffectSpec in _specs.iterate():
		_pre_remove_spec(spec)
	_specs.clear()
	_has_specs = false
	_effect_counts.clear()
	
	for spec: AttributeEffectSpec in removed_specs:
		_post_remove_spec(spec)
	
	_current_value = _validate_current_value(_base_value)
	_locked = false


func _remove_from_effect_counts(spec: AttributeEffectSpec) -> void:
	if _effect_counts.has(spec.get_effect()):
		var new_count: int = _effect_counts[spec.get_effect()] - 1
		if new_count <= 0:
			_effect_counts.erase(spec.get_effect())
		else:
			_effect_counts[spec.get_effect()] = new_count


func _remove_spec_at_index(spec: AttributeEffectSpec, index: int, from_effect_counts: bool) -> void:
	_pre_remove_spec(spec)
	_specs.remove_at(spec, index)
	_has_specs = !_specs.is_empty()
	if from_effect_counts:
		_remove_from_effect_counts(spec)
	_post_remove_spec(spec)


func _pre_remove_spec(spec: AttributeEffectSpec) -> void:
	_run_callbacks(spec, AttributeEffectCallback._Function.PRE_REMOVE)
	spec._is_added = false


func _post_remove_spec(spec: AttributeEffectSpec) -> void:
	if spec.get_effect().should_emit_removed_signal():
		effect_removed.emit(spec)
	_run_callbacks(spec, AttributeEffectCallback._Function.REMOVED)


## Tests the addition of [param spec] by evaluating it's potential add [AttributeEffectCondition]s
## and that of all BLOCKER type effects.
func _test_add_conditions(spec: AttributeEffectSpec) -> bool:
	# Check spec's own conditions
	if spec.get_effect().has_add_conditions():
		if !_test_conditions(spec, spec, spec.get_effect().add_conditions, effect_add_blocked):
			spec._last_add_result = AddEffectResult.BLOCKED_BY_CONDITION
			return false
	
	# Iterate BLOCKER effects
	if _specs.has_blockers():
		for blocker: AttributeEffectSpec in _specs.iterate_blockers():
			# Ignore expired - they arent removed until later in the frame sometimes
			if blocker.is_expired():
				continue
			
			if !_test_conditions(spec, blocker, blocker.get_effect().add_blockers, effect_add_blocked):
				spec._last_add_result = AddEffectResult.BLOCKED_BY_BLOCKER
				return false
	
	return true


## Tests the applying of [param spec] by evaluating it's potential apply [AttributeEffectCondition]s
## and that of all BLOCKER type effects.
func _test_apply_conditions(spec: AttributeEffectSpec) -> bool:
	# Check spec's own conditions
	if spec.get_effect().has_apply_conditions():
		if !_test_conditions(spec, spec, spec.get_effect().apply_conditions, effect_apply_blocked):
			return false
	
	# Iterate BLOCKER effects
	if _specs.has_blockers():
		for blocker: AttributeEffectSpec in _specs.iterate_blockers():
			# Ignore expired - they arent removed until later in the frame sometimes
			if blocker.is_expired():
				continue
			
			if !_test_conditions(spec, blocker, blocker.get_effect().apply_blockers, effect_apply_blocked):
				return false
	return true


func _test_conditions(spec_to_test: AttributeEffectSpec, condition_source: AttributeEffectSpec,
 conditions: Array[AttributeEffectCondition], _signal: Signal) -> bool:
	for condition: AttributeEffectCondition in conditions:
		if !condition.meets_condition(self, spec_to_test):
			spec_to_test._last_blocked_by = condition
			if condition.emit_blocked_signal:
				_signal.emit(spec_to_test, condition_source)
			return false
	return true


func _update_processing() -> void:
	var can_process: bool = !Engine.is_editor_hint() && _has_specs && allow_effects
	set_process(can_process && effects_process_function == ProcessFunction.PROCESS)
	set_physics_process(can_process && effects_process_function == ProcessFunction.PHYSICS_PROCESS)


func _get_modified_value(spec: AttributeEffectSpec) -> float:
	var modified_value: float = spec.get_effect().value.get_modified(self, spec)
	for modifier_spec: AttributeEffectSpec in _specs.iterate_modifiers():
		if modifier_spec.is_expired():
			continue
		modified_value = modifier_spec.get_effect().value_modifiers.modify_value(modified_value, self, spec)
	return modified_value


func _get_modified_period(spec: AttributeEffectSpec) -> float:
	var modified_period: float = spec.get_effect().period_in_seconds.get_modified(self, spec)
	for modifier_spec: AttributeEffectSpec in _specs.iterate_modifiers():
		if modifier_spec.is_expired():
			continue
		modified_period = modifier_spec.get_effect().period_modifiers.modify_period(modified_period, self, spec)

	return modified_period

func _get_modified_duration(spec: AttributeEffectSpec) -> float:
	var modified_duration: float = spec.get_effect().duration_in_seconds.get_modified(self, spec)
	for modifier_spec: AttributeEffectSpec in _specs.iterate_modifiers():
		if modifier_spec.is_expired():
			continue
		modified_duration = modifier_spec.get_effect().duration_modifiers.modify_duration(modified_duration, self, spec)
	return modified_duration


func _initialize_spec(spec: AttributeEffectSpec) -> void:
	assert(!spec.is_initialized(), "spec (%s) already initialized" % spec)
	if spec.get_effect().has_period() && spec.get_effect().initial_period:
		spec.remaining_period = _get_modified_period(spec)
	if spec.get_effect().has_duration():
		spec.remaining_duration = _get_modified_duration(spec)
	spec._initialized = true


## Applies the [param spec]. Returns true if it should be removed (hit apply limit),
## false if not.
func _apply_permanent_spec(spec: AttributeEffectSpec, current_tick: int, to_remove: Dictionary, index: int) -> void:
	# Get the modified value
	spec._pending_effect_value = _get_modified_value(spec)
	
	# Calculate the attribute's new value
	spec._pending_attribute_value_raw = spec.get_effect().apply_calculator(_base_value, 
	_current_value, spec._pending_effect_value)
	
	# Validate the attribute's value
	spec._pending_attribute_value = _validate_base_value(spec._pending_attribute_value_raw)
	
	# Check apply conditions
	if !_test_apply_conditions(spec):
		spec._clear_pending_values()
		return
	
	# Set "last" values
	spec._last_effect_value = spec._pending_effect_value
	spec._last_prior_attribute_value = _base_value
	spec._last_set_attribute_value = spec._pending_attribute_value
	
	# Clear pending value
	spec._clear_pending_values()
	
	# Increase apply count
	spec._apply_count += 1
	
	# Set tick last applied
	spec._tick_last_applied = current_tick
	
	# Add to history
	if has_history() && spec.get_effect().should_log_history():
		_history._add_to_history(spec)
	
	# Mark for removal if it hit apply limit (& remove from effect counts)
	if spec.hit_apply_limit():
		to_remove[index] = spec
		_remove_from_effect_counts(spec)
	
	# Apply it
	_base_value = spec._last_set_attribute_value
	if _base_value != spec._last_prior_attribute_value:
		base_value_changed.emit(spec._last_prior_base_value, spec)
	
	# Emit signals
	_run_callbacks(spec, AttributeEffectCallback._Function.APPLIED)
	effect_applied.emit(spec)
	spec.applied.emit(self)
	
	# Update current value if needed
	if _base_value != spec._last_prior_attribute_value:
		_update_current_value()


## Adds [param amount] to the effect stack. This effect must be stackable
## (see [method is_stackable]) and [param amount] must be > 0.
## [br]Automatically emits [signal effect_stack_count_changed].
func _add_to_stack(spec: AttributeEffectSpec, amount: int = 1) -> void:
	assert(spec.get_effect().is_stackable(), "spec (%s) not stackable" % spec)
	assert(amount > 0, "amount(%s) <= 0" % amount)
	
	var previous_stack_count: int = spec._stack_count
	spec._stack_count += amount
	_run_stack_callbacks(spec, previous_stack_count)
	effect_stack_count_changed.emit(spec, previous_stack_count)


## Removes [param amount] from the effect stack. This effect must be stackable
## (see [method is_stackable]), [param amount] must be > 0, and 
## [method get_stack_count] - [param amount] must be > 0.
## [br]Automatically emits [signal effect_stack_count_changed].
func _remove_from_stack(spec: AttributeEffectSpec, amount: int = 1) -> void:
	assert(spec.get_effect().is_stackable(), "spec (%s) not stackable" % spec)
	assert(amount > 0, "amount(%s) <= 0" % amount)
	assert(spec._stack_count - amount > 0, "amount(%s) - spec._stack_count(%s) <= 0 fopr spec (%s)"\
		% [amount, spec._stack_count, spec])
	
	var previous_stack_count: int = spec._stack_count
	spec._stack_count -= amount
	_run_stack_callbacks(spec, previous_stack_count)
	effect_stack_count_changed.emit(spec, previous_stack_count)


## Runs the callback [param _function] on all [AttributeEffectCallback]s who have
## implemented that function.
func _run_callbacks(spec: AttributeEffectSpec, _function: AttributeEffectCallback._Function) -> void:
	if !AttributeEffectCallback._can_run(_function, spec.get_effect()):
		return
	var function_name: String = AttributeEffectCallback._function_names[_function]
	for callback: AttributeEffectCallback in spec.get_effect()._callbacks_by_function.get(_function):
		callback.call(function_name, self, spec)


func _run_stack_callbacks(spec: AttributeEffectSpec, previous_stack_count: int) -> void:
	var function_name: String = AttributeEffectCallback._function_names\
	[AttributeEffectCallback._Function.STACK_CHANGED]
	
	for callback: AttributeEffectCallback in spec.get_effect()._callbacks_by_function\
	.get(AttributeEffectCallback._Function.STACK_CHANGED):
		callback.call(function_name, self, spec, previous_stack_count)


func _to_string() -> String:
	return "Attribute(id:%s)" % id
