## A configurable resource that causes changes to an [Attribute].
@tool
class_name AttributeEffect extends Resource

## The type of effect.
## [br] NOTE: This enum's structure determines the ordering of [AttributeEffectSpecArray].
enum Type {
	## Makes permanent changes to an [Attribute]'s base value.
	PERMANENT = 0,
	## Makes temporary changes to an [Attribute] reflected in 
	## [method Attribute.get_current_value].
	TEMPORARY = 1,
}

## Determines how this effect can be stacked on an [Attribute], if at all.
enum StackMode {
	## Stacking is not allowed.
	DENY = 0,
	## Stacking is not allowed and an assertion will be called
	## if there is an attempt to stack this effect on an [Attribute].
	DENY_ERROR = 1,
	## Attribute effects are seperate, a new [AttributeEffectSpec] is created
	## for every instance added to an [Attribute].
	SEPERATE = 2,
	## Attribute effects are combined into one [AttributeEffectSpec] whose
	## [member AttributeEffectSpec._stack_count] is increased accordingly.
	COMBINE = 3,
}

## Determines how the effect is applied time-wise.
enum DurationType {
	## The effect is applied to an [Attribute] and remains until it is explicitly
	## removed.
	INFINITE = 0,
	## The effect is applied to an [Attribute] and is removed automatically
	## after [member duration_seconds].
	HAS_DURATION = 1,
	## The effect is immediately applied to an [Attribute] and does not remain
	## stored on it.
	INSTANT = 2,
}

## The ID of this attribute effect.
@export var id: StringName

## Metadata tags to help identify an effect. Similar to an [AttributeContainer]'s tags.
## One use case would be to use tags as a category of effect, i.e. "poison" for all
## poison damage effects.
@export var tags: Array[StringName]

## The type of effect, see [enum AttributeEffect.Type]
@export var type: Type = Type.PERMANENT:
	set(_value):
		type = _value
		if type != Type.PERMANENT && duration_type == DurationType.INSTANT:
			# INSTANT not compatible with TEMPORARY or BLOCKER
			duration_type = DurationType.INFINITE
		notify_property_list_changed()

## If true, this effect has a value that applies to an [Attribute].
@export var has_value: bool = true:
	set(_value):
		has_value = _value
		notify_property_list_changed()

## The direct effect to [member Attribute.value]
@export var value: float

## Determines how the effect is applied to an [Attribute] (i.e. added, multiplied, etc).
@export var value_calculator: AttributeEffectCalculator

## The priority to be used to determine the order when processing & applying [AttributeEffect]s
## on an [Attribute]. Greater priorities will be processed & applied first. If two effects have
## equal priorities, the effect most recently added to the attribute is processed first. 
## If you want a temporary effect to override a value on an attribute & not have that value 
## modified by any other effects, then the priority should be lesser than other effects that 
## can be applied so the override effect is applied last.
## [br]NOTE: Effects are first sorted by type: [enum Type.BLOCKER], [enum Type.PERMANENT], [enum Type.TEMPORARY].
## [br]NOTE: Priority is not used in processing of period & duration.
@export var priority: int = 0

@export_group("Signals")

## If true, [signal Attribute.effect_added] will be emitted every time an
## [AttributeEffectSpec] of this effect is added to an [Attribute].
@export var _emit_added_signal: bool = false

## If true, [signal Attribute.effect_applied] will be emitted every time an
## [AttributeEffectSpec] of this effect is successfully applied on an [Attribute].
## [br]NOTE: ONLY AVAILABLE FOR [enum Type.PERMANENT].
@export var _emit_applied_signal: bool = false

## If true, [signal Attribute.effect_removed] will be emitted every time an
## [AttributeEffectSpec] of this effect is removed from an [Attribute].
@export var _emit_removed_signal: bool = false

@export_group("Duration")

## How long the effect lasts.
@export var duration_type: DurationType:
	set(_value):
		if type == Type.TEMPORARY && _value == DurationType.INSTANT:
			duration_type = DurationType.INFINITE
			return
		if type == Type.PERMANENT:
			has_value = true
		duration_type = _value
		notify_property_list_changed()

## The amount of time in seconds this [AttributeEffect] lasts.
@export_range(0.0, 100.0, 1.0, "or_greater", "hide_slider") var duration_in_seconds: float = 0.0:
	set(_value):
		duration_in_seconds = max(0.0, _value)
		notify_property_list_changed()

## If the effect should automatically be applied when it's duration expires.
## [br]NOTE: Only available for [enum Type.PERMANENT] effects.
@export var _apply_on_expire: bool = false:
	set(_value):
		_apply_on_expire = _value
		notify_property_list_changed()

@export_group("Apply Limit")

## If true, [member apply_limit_amount] is the maximum amount of times an effect
## can apply. If the limit is hit, the effect is removed immediately.
## [br]NOTE: Only available for [enum Type.PERMANENT] effects.
@export var _apply_limit: bool = false:
	set(_value):
		_apply_limit = _value
		notify_property_list_changed()

## The maximum amount of times this effect can be applied to an [Attribute], inclusive. If this
## number is reached, the effect is then instantly removed from the [Attribute].
## [br]NOTE: Only available for [enum Type.PERMANENT] effects.
@export_range(1, 100, 1, "or_greater", "hide_slider") var apply_limit_amount: int:
	set(_value):
		if !Engine.is_editor_hint() && has_apply_limit():
			assert(_value > 0, "apply_limit_amount must be > 0")
		apply_limit_amount = _value

@export_group("Period")

## Amount of time, in seconds, between when this effect is applied to an [Attribute].
## [br]Zero or less means every frame.
## [br]NOTE: Only available for [enum Type.PERMANENT] effects.
@export_range(0.0, 100.0, 1, "or_greater", "hide_slider") var period_in_seconds: float = 0.0:
	set(_value):
		period_in_seconds = max(0.0, _value)

## If [member period_in_seconds] should apply as a "delay" between when this effect 
## is added to an [Attribute] and its first time applying.
## [br]NOTE: Only available for [enum Type.PERMANENT] effects.
@export var initial_period: bool = false

## For special edge cases, if true the effect will be applied on it's expiration if
## the remaining period has reached 0.0 at the same frame. If [member _apply_on_expire]
## is true, this property is meaningless.
## [br]For example, if an effect has a duration of 5 seconds, and a period of 1, it
## will be applied when it expires as the remaining period for the next application
## will reach zero on the same frame.
## [br]NOTE: Only available for [enum Type.PERMANENT] effects.
@export var _apply_on_expire_if_period_is_zero: bool = false

@export_group("Stacking")

## The [StackMode] to use when duplicate [AttributeEffect]s are found.
@export var stack_mode: StackMode:
	set(_value):
		if duration_type == DurationType.INSTANT && _value == StackMode.COMBINE:
			stack_mode = StackMode.DENY
			return
		stack_mode = _value
		notify_property_list_changed()

@export_group("Attribute History")

## If true, anytime this effect is applied to an [Attribute] it is registered
## in that attribute's [AttributeHistory] if one exists.
@export var _log_history: bool = false

@export_group("Conditions")

## All [AttributeEffectCondition]s that must be met for this effect to be
## added to an [Attribute]. This array can safely be directly modified or set.
##[br]NOTE: Not supported for INSTANT effects, as they are just applied & not added.
@export var add_conditions: Array[AttributeEffectCondition]

## All [AttributeEffectCondition]s that must be met for this effect to be
## applied to an [Attribute]. This array can safely be directly modified or set.[br]
## [br]NOTE: Only for [enum Type.PERMANENT] effects, as TEMPORARY effects are [b]always[/b]
## applied if the effect was added.
@export var apply_conditions: Array[AttributeEffectCondition]

@export_group("Self Modifiers")

## Modififiers to modify [member value]. For PERMANENT effects these modifify
## this instance's value. For MODIFIER effects, these modify the effects of
## other attributes.
## [br]NOTE: Be careful when using these with TEMPORARY effects. They are 
## not called in a scheduled manner so it could result in unpredictable
## values being set.
@export var _value_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		if OS.is_debug_build():
			_remove_invalid_modifiers(_value)
		if !Engine.is_editor_hint():
			_value.sort_custom(AttributeEffectModifier.sort_descending)
		_value_modifiers = _value
		if Engine.is_editor_hint():
			notify_property_list_changed.call_deferred()

## Modififiers to modify [member period_in_seconds].
## NOTE: Only for [enum Type.PERMANENT] effects.
@export var _period_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		if OS.is_debug_build():
			_remove_invalid_modifiers(_value)
		if !Engine.is_editor_hint():
			_value.sort_custom(AttributeEffectModifier.sort_descending)
		_period_modifiers = _value
		if Engine.is_editor_hint():
			notify_property_list_changed.call_deferred()

## Modififiers to modify [member duration_in_seconds].
@export var _duration_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		if OS.is_debug_build():
			_remove_invalid_modifiers(_value)
		if !Engine.is_editor_hint():
			_value.sort_custom(AttributeEffectModifier.sort_descending)
		_duration_modifiers = _value
		if Engine.is_editor_hint():
			notify_property_list_changed.call_deferred()

@export_group("Callbacks")

## List of [AttributeEffectCallback]s to extend the functionality of this effect
## further than modifying the value of an [Attribute].
@export var _callbacks: Array[AttributeEffectCallback]:
	set(_value):
		_callbacks = _value
		if !Engine.is_editor_hint():
			for callback: AttributeEffectCallback in _callbacks:
				_add_callback_internal(callback, false)

@export_group("Effect Blocker")

## If true, this effect has [member add_blockers] and/or [member apply_blockers] which
## are sets of [AttributeEffectCondition]s that can block other [AttributeEffect]s
## from applying while this effect is active.
@export var is_blocker: bool = false

## Blocks other [AttributeEffect]s from being added to an [Attribute] if they
## do NOT meet any of these conditions.
@export var add_blockers: Array[AttributeEffectCondition]

## Blocks other [AttributeEffect]s from being applied to an [Attribute] if they
## do NOT meet any of these conditions.
@export var apply_blockers: Array[AttributeEffectCondition]

@export_group("Effect Modifiers")

## If true, this effect has TODO which modify the properties of other [AttributeEffect]s.
@export var is_modifier: bool = false



var _callbacks_by_function: Dictionary = {}

func _init(_id: StringName = "") -> void:
	id = _id
	if Engine.is_editor_hint():
		return
	
	# Callback initialization
	for _function: int in AttributeEffectCallback._Function.values():
		_callbacks_by_function[_function] = []


func _validate_property(property: Dictionary) -> void:
	if property.name == "_has_value":
		if must_have_value():
			_no_editor(property)
	
	if property.name == "value" || property.name == "value_calculator":
		if !has_value:
			_no_editor(property)
		return
	
	if property.name == "_emit_applied_signal":
		if !can_emit_applied_signal():
			_no_editor(property)
		return
	
	if property.name == "_emit_added_signal":
		if !can_emit_added_signal():
			_no_editor(property)
		return
	
	if property.name == "_emit_removed_signal":
		if !can_emit_removed_signal():
			_no_editor(property)
		return
	
	if property.name == "duration_type":
		var exclude: Array = [] if can_be_instant() else [DurationType.INSTANT]
		property.hint_string = _format_enum(DurationType, exclude)
		return
	
	if property.name == "duration_in_seconds":
		if !has_duration():
			_no_editor(property)
		return
	
	if property.name == "_apply_on_expire":
		if !can_apply_on_expire():
			_no_editor(property)
		return
	
	if property.name == "_apply_limit":
		if !can_have_apply_limit():
			_no_editor(property)
		return
	
	if property.name == "apply_limit_amount":
		if !can_have_apply_limit() || !_apply_limit:
			_no_editor(property)
		return
	
	if property.name == "period_in_seconds" || property.name == "initial_period":
		if !has_period():
			_no_editor(property)
		return
	
	if property.name == "_apply_on_expire_if_period_is_zero":
		if !can_apply_on_expire_if_period_is_zero() || is_apply_on_expire():
			_no_editor(property)
		return
	
	if property.name == "stack_mode":
		if is_instant():
			_no_editor(property)
		return
	
	if property.name == "_log_history":
		if !can_log_history():
			_no_editor(property)
		return
	
	if property.name == "add_conditions":
		if !has_add_conditions():
			_no_editor(property)
		return
	
	if property.name == "apply_conditions":
		if !has_apply_conditions():
			_no_editor(property)
		return
	
	if property.name == "_value_modifiers":
		if !has_value:
			_no_editor(property)
		return
	
	if property.name == "_period_modifiers":
		if !has_period():
			_no_editor(property)
		return
	
	if property.name == "_duration_modifiers":
		if !has_duration():
			_no_editor(property)
		return
	
	if property.name == "add_blockers" || property.name == "apply_blockers":
		if !is_blocker:
			_no_editor(property)
		return


func _remove_invalid_modifiers(modifiers: Array[AttributeEffectModifier]) -> void:
	if !OS.is_debug_build():
		push_error("this function must only be run in debug builds")
	for index: int in range(modifiers.size() -1, -1, -1):
		var modifier :AttributeEffectModifier = modifiers[index]
		if modifier != null && !modifier._validate_and_warn(self):
			modifiers[index] = null


## Helper method for _validate_property.
func _no_editor(property: Dictionary) -> void:
	property.usage = PROPERTY_USAGE_STORAGE


func _format_enum(_enum: Dictionary, exclude: Array) -> String:
	var hint_string: Array[String] = []
	for name: String in _enum.keys():
		var value: int = _enum[name]
		if exclude.has(value):
			continue
		hint_string.append("%s:%s" % [name.to_camel_case().capitalize(), value])
	return ",".join(hint_string)


## Adds the [param callback] from this effect. An assertion is in place to prevent
## multiple [AttributeEffectCallback]s of the same instance being added to an effect.
func add_callback(callback: AttributeEffectCallback) -> void:
	_add_callback_internal(callback, true)


func _add_callback_internal(callback: AttributeEffectCallback, add_to_list: bool) -> void:
	assert(!add_to_list || !_callbacks.has(callback), "callback (%s) already exists" % callback)
	AttributeEffectCallback._set_functions(callback)
	if add_to_list:
		_callbacks.append(callback)
	for _function: AttributeEffectCallback._Function in callback._functions:
		assert(AttributeEffectCallback._can_run(_function, self), "")
		_callbacks_by_function[_function].append(callback)
	callback._added_to_effect(self)


## Removes the [param callback] from this effect. Returns true if the callback
## existed & was removed, false if not.
func remove_callback(callback: AttributeEffectCallback) -> bool:
	if !_callbacks.has(callback):
		return false
	_callbacks.erase(callback)
	for _function: AttributeEffectCallback._Function in callback._functions:
		_callbacks_by_function[_function].erase(callback)
	callback._removed_from_effect(self)
	return true


## Adds the [param modifier] to apply on [member value], returning true if
## successfully added. Returns false if not added due to an instance already existing &
## [member AttributeEffectModifier.duplicate_instances] being false, or if
## [method AttributeEffectModifier._validate_and_warn] returned false.
func add_value_modifier(modifier: AttributeEffectModifier) -> bool:
	assert_has_value()
	return _add_modifier(modifier, _value_modifiers)


## Adds the [param modifier] to apply on [member period_in_seconds], returning true if
## successfully added. Returns false if not added due to an instance already existing &
## [member AttributeEffectModifier.duplicate_instances] being false, or if
## [method AttributeEffectModifier._validate_and_warn] returned false.
func add_period_modifier(modifier: AttributeEffectModifier) -> bool:
	assert_has_period()
	return _add_modifier(modifier, _period_modifiers)


## Adds the [param modifier] to apply on [member duration_in_seconds], returning true if
## successfully added. Returns false if not added due to an instance already existing &
## [member AttributeEffectModifier.duplicate_instances] being false, or if
## [method AttributeEffectModifier._validate_and_warn] returned false.
func add_duration_modifier(modifier: AttributeEffectModifier) -> bool:
	assert_has_duration()
	return _add_modifier(modifier, _duration_modifiers)


## Internal method to add a modifier
func _add_modifier(modifier: AttributeEffectModifier, 
array: Array[AttributeEffectModifier]) -> bool:
	assert(modifier != null, "modifier is null")
	if !modifier._validate_and_warn(self):
		return false
	
	if !modifier.duplicate_instances && array.has(modifier):
		return false
	
	var index: int = 0
	for other_modifier: AttributeEffectModifier in array:
		if modifier.priority >= other_modifier.priority:
			array.insert(index, modifier)
			break
		index += 1
	if index == array.size(): # Wasn't added in loop, append it to back
		array.append(modifier)
	
	return true


## Returns true if the [param modifier] exists for the [member value], false if not.
func has_value_modifier(modifier: AttributeEffectModifier) -> bool:
	assert_has_value()
	return _value_modifiers.has(modifier)


## Returns true if the [param modifier] exists for the [member period_in_seconds], false if not.
func has_period_modifier(modifier: AttributeEffectModifier) -> bool:
	assert_has_period()
	return _period_modifiers.has(modifier)


## Returns true if the [param modifier] exists for the [member duration_in_seconds], false if not.
func has_duration_modifier(modifier: AttributeEffectModifier) -> bool:
	assert_has_duration()
	return _duration_modifiers.has(modifier)


## Removes the [param modifier] on [member value]. [param remove_all] can be true
## to remove all duplicate instances of the [param modifier], otherwise if false it will
## only remove the first instance found.
func remove_value_modifier(modifier: AttributeEffectModifier, remove_all: bool = false) -> void:
	assert_has_value()
	_remove_modifier(modifier, remove_all, _value_modifiers)


## Removes the [param modifier] on [member period_in_seconds]. [param remove_all] can be true
## to remove all duplicate instances of the [param modifier], otherwise if false it will
## only remove the first instance found.
func remove_period_modifier(modifier: AttributeEffectModifier, remove_all: bool = false) -> void:
	assert_has_period()
	_remove_modifier(modifier, remove_all, _period_modifiers)


## Removes the [param modifier] on [member duration_in_seconds]. [param remove_all] can be true
## to remove all duplicate instances of the [param modifier], otherwise if false it will
## only remove the first instance found.
func remove_duration_modifier(modifier: AttributeEffectModifier, remove_all: bool = false) -> void:
	assert_has_duration()
	_remove_modifier(modifier, remove_all, _duration_modifiers)


func _remove_modifier(modifier: AttributeEffectModifier, remove_all: bool,
array: Array[AttributeEffectModifier]) -> void:
	array.erase(modifier)
	if remove_all:
		while array.has(modifier):
			array.erase(modifier)


## Returns a duplicated [Array] of all [AttributeEffecftModifier]s for [member value].
func get_value_modifiers() -> Array[AttributeEffectModifier]:
	assert_has_value()
	return _value_modifiers.duplicate(false)


## Returns a duplicated [Array] of all [AttributeEffecftModifier]s for [member period_in_seconds].
func get_period_modifiers() -> Array[AttributeEffectModifier]:
	assert_has_period()
	return _period_modifiers.duplicate(false)


## Returns a duplicated [Array] of all [AttributeEffecftModifier]s for [member duration_in_seconds].
func get_duration_modifiers() -> Array[AttributeEffectModifier]:
	assert_has_duration()
	return _duration_modifiers.duplicate(false)


## Applies the [member value_calculator] on the [param attribute_value] and
## [param effect_value], returning the result. It must always be ensured that
## the [param effect_value] comes from [b]this effect[/b], otherwise results
## will be unexpected.
func apply_calculator(attr_base_value: float, attr_current_value: float, effect_value: float) -> float:
	assert_has_value()
	return value_calculator._calculate(attr_base_value, attr_current_value, effect_value)


## Returns the [member value] after applying all value [AttributeEffectModifier]s to it.
func get_modified_value(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert_has_value()
	return _get_modified(value, attribute, spec, _value_modifiers)


## Returns the [member period_in_seconds] after applying all period [AttributeEffectModifier]s to it.
func get_modified_period(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert_has_period()
	return _get_modified(period_in_seconds, attribute, spec, _period_modifiers)


## Returns the [member duration_in_seconds] after applying all duration [AttributeEffectModifier]s to it.
func get_modified_duration(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert_has_duration()
	return _get_modified(duration_in_seconds, attribute, spec, _duration_modifiers)


## Helper function for the above functions
func _get_modified(to_modify: float, attribute: Attribute, spec: AttributeEffectSpec, 
modifiers: Array[AttributeEffectModifier]) -> float:
	assert_spec_is_self(spec)
	var modified: float = to_modify
	for modifier: AttributeEffectModifier in _value_modifiers:
		if !modifier.should_modify(attribute, spec):
			continue
		modified = modifier._modify(modified, attribute, spec)
		if modifier.stop_processing_modifiers:
			break
	return modified


## Shorthand function to create an [AttributeEffectSpec] for this [AttributeEffect].
## [br]Can be overridden for custom [AttributeEffectSpec] implementations if you know
## what you are doing.
func to_spec() -> AttributeEffectSpec:
	return AttributeEffectSpec.new(self)


func _to_string() -> String:
	return "AttributeEffect(id:%s)" % id


##########################################
## Helper functions for feature support ##
##########################################

## Whether or not this effect MUST have [member value].
func must_have_value() -> bool:
	return type == Type.PERMANENT


## Asserts [method has_value] returns true.
func assert_has_value() -> void:
	assert(has_value, "effect does have a value")


## Returns true if this effect supports a [member duration_type] of 
## [enum DurationType.INSTANT].
func can_be_instant() -> bool:
	return type == Type.PERMANENT


## Returns true if this effect supports [member duration_type] of 
## [enum DurationType.INSTANT] and is currently INSTANT.
func is_instant() -> bool:
	return can_be_instant() && duration_type == DurationType.INSTANT


## Helper function returning true if the effect's type is 
## [enum AttributeEffect.Type.PERMANENT], false if not.
func is_permanent() -> bool:
	return type == AttributeEffect.Type.PERMANENT


## Helper function returning true if the effect's type is 
## [enum AttributeEffect.Type.TEMPORARY], false if not.
func is_temporary() -> bool:
	return type == AttributeEffect.Type.TEMPORARY


## Whether or not this effect supports [member add_conditions]
func has_add_conditions() -> bool:
	return duration_type != DurationType.INSTANT


## Whether or not this effect supports [member apply_conditions]
func has_apply_conditions() -> bool:
	return type == Type.PERMANENT


## Whether or not this effect can emit [signal Attribute.effect_added].
func can_emit_added_signal() -> bool:
	return duration_type != DurationType.INSTANT


## Whether or not this effect should cause [signal Attriubte.effect_added] to be
## emitted when a spec of this effect is added.
func should_emit_added_signal() -> bool:
	return can_emit_added_signal() && _emit_added_signal


## Whether or not this effect can emit [signal Attribute.effect_applied].
func can_emit_applied_signal() -> bool:
	return type == Type.PERMANENT


## Whether or not this effect should cause [signal Attriubte.effect_applied] to be
## emitted when a spec of this effect is applied.
func should_emit_applied_signal() -> bool:
	return can_emit_applied_signal() && _emit_applied_signal


## Whether or not this effect can emit [signal Attribute.effect_removed].
func can_emit_removed_signal() -> bool:
	return duration_type != DurationType.INSTANT


## Whether or not this effect should cause [signal Attriubte.effect_removed] to be
## emitted when a spec of this effect is removed.
func should_emit_removed_signal() -> bool:
	return can_emit_removed_signal() && _emit_removed_signal


## Whether or not this effect supports [member apply_on_expire]
func can_apply_on_expire() -> bool:
	return duration_type == DurationType.HAS_DURATION && type == Type.PERMANENT


## Whether or not this effect should automatically apply on the same frame that it expires.
## Returns true if [method can_apply_on_expire] and [member _apply_on_expire] are both true.
func is_apply_on_expire() -> bool:
	return can_apply_on_expire() && _apply_on_expire


## Whether or not this effect supports [member _apply_on_expire_if_period_is_zero]
func can_apply_on_expire_if_period_is_zero() -> bool:
	return has_period()


## Whether or not this effect should automatically apply on the same frame that it expires
## ONLY IF the remaining period is <= 0.0
## Returns true if [method can_apply_on_expire_if_period_is_zero] and 
## [member _apply_on_expire_if_period_is_zero] are both true.
func is_apply_on_expire_if_period_is_zero() -> bool:
	return can_apply_on_expire_if_period_is_zero() && _apply_on_expire_if_period_is_zero


## Whether or not this effect supports [member _apply_limit] & [member apply_limit_amount]
func can_have_apply_limit() -> bool:
	return duration_type != DurationType.INSTANT && type == Type.PERMANENT


## Whether or not this effect has an [member apply_limit_amount] (that maximum number
## of times it can apply before being instantly removed)
## Returns true if [method can_have_apply_limit] and [member _apply_limit] are both true.
func has_apply_limit() -> bool:
	return can_have_apply_limit() && _apply_limit


## Returns true if this effect has a [member duration_in_seconds].
func has_duration() -> bool:
	return duration_type == DurationType.HAS_DURATION


## Asserts [method has_duration] returns true.
func assert_has_duration() -> void:
	assert(has_duration(), "effect does not have a duration_in_seconds")


## Returns true if this effect has a [member period_in_seconds].
func has_period() -> bool:
	return type == Type.PERMANENT && !is_instant()


## Asserts [method has_period] returns true.
func assert_has_period() -> void:
	assert(has_period(), "effect does not have a period_in_seconds")


## [method assert]s that [member AttributeEffectSpec._effect] for [param spec]
## is equal to this instance.
func assert_spec_is_self(spec: AttributeEffectSpec) -> void:
	assert(spec._effect == self, "self != spec._effect (%s)" % spec._effect)


## Returns true if this effect supports [member _log_history].
func can_log_history() -> bool:
	return type == Type.PERMANENT


## Returns true if this effect's applications should be logged in an [AttributeHistory].
func should_log_history() -> bool:
	return can_log_history() && _log_history
