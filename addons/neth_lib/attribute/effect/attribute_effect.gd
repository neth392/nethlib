## An effect that can cause changes to an [Attribute]'s value, among many other functionalities.
@tool
class_name AttributeEffect extends Resource

enum ValueType {
	## There is no [member value]
	NONE = 0,
	## [member value] is "static", set to a specific number via the inspector or code.
	STATIC = 1,
	## [member value] is derived from an [Attribute].
	DERIVED_FROM_ATTRIBUTE = 2,
}

## The type of effect.
## [br] NOTE: This enum's structure determines the ordering of [AttributeEffectSpecArray].
enum Type {
	## Makes temporary changes to an [Attribute] reflected in 
	## [method Attribute.get_current_value].
	TEMPORARY = 0,
	## Makes permanent changes to an [Attribute]'s base value.
	PERMANENT = 1,
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

## The priority to be used to determine the order when processing & applying [AttributeEffect]s
## on an [Attribute]. Greater priorities will be processed & applied first. If two effects have
## equal priorities, the effect most recently added to the attribute is processed first. 
## If you want a temporary effect to override a value on an attribute & not have that value 
## modified by any other effects, then the priority should be lesser than other effects that 
## can be applied so the override effect is applied last.
## [br]NOTE: Effects are first sorted by type [enum Type.TEMPORARY] then [enum Type.PERMANENT].
@export var priority: int = 0

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
		if type == Type.PERMANENT && value_type == ValueType.NONE:
			value_type = ValueType.STATIC
		notify_property_list_changed()

## If true, this effect must have a [member value] which applies to an [Attribute].
@export var value_type: ValueType:
	set(_value):
		value_type = _value
		notify_property_list_changed()

## The value that is applied to an [Attribute]'s value (base or current, based on
## [member type]).
@export var value: ModifiableValue = ModifiableValue.new()

## Determines how the [member value] is applied to an [Attribute] (i.e. added, multiplied, etc).
@export var value_calculator: AttributeEffectCalculator

@export_group("Signals")

## If true, [signal Attribute.effect_added] will be emitted every time an
## [AttributeEffectSpec] of this effect is added to an [Attribute].
@export var _emit_added_signal: bool = false

## If true, [signal Attribute.effect_applied] will be emitted every time an
## [AttributeEffectSpec] of this effect is successfully applied on an [Attribute].
## [br]NOTE: ONLY AVAILABLE FOR [enum Type.PERMANENT] as TEMPORARY effects are not reliably applied.
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
		duration_type = _value
		notify_property_list_changed()

## The amount of time in seconds this [AttributeEffect] lasts.
@export var duration_in_seconds: ModifiableValue = ModifiableValue.new()

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
@export var period_in_seconds: ModifiableValue = ModifiableValue.new()

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
## [br]NOTE: When using with TEMPORARY effects, [method Attribute.update_current_value]
## will need to be called manually if a condition changes. That fucntion is only automatically
## called when an effect is added/removed or a PERMANENT effect is applied.
@export var apply_conditions: Array[AttributeEffectCondition]

@export_group("Callbacks")

## List of [AttributeEffectCallback]s to extend the functionality of this effect
## further than modifying the value of an [Attribute].
@export var _callbacks: Array[AttributeEffectCallback]:
	set(_value):
		_callbacks = _value
		if !Engine.is_editor_hint():
			for callback: AttributeEffectCallback in _callbacks:
				_add_callback_internal(callback, false)
		else:
			for callback: AttributeEffectCallback in _callbacks:
				callback._run_assertions(self)

@export_group("Blockers")

## If true, this effect has [member add_blockers] and/or [member apply_blockers] which
## are sets of [AttributeEffectCondition]s that can block other [AttributeEffect]s
## from applying while this effect is active.
@export var _blocker: bool = false

## Blocks other [AttributeEffect]s from being added to an [Attribute] if they
## do NOT meet any of these conditions.
@export var add_blockers: Array[AttributeEffectCondition]

## Blocks other [AttributeEffect]s from being applied to an [Attribute] if they
## do NOT meet any of these conditions.
@export var apply_blockers: Array[AttributeEffectCondition]

@export_group("Modifiers")

## If true, this effect has TODO which modify the properties of other [AttributeEffect]s.
@export var _modifier: bool = false

## Modifies the [member value] of other [AttributeEffect]s.
@export var value_modifiers: AttributeEffectModifierArray

## Modifies the [member period_in_seconds] of other [AttributeEffect]s.
@export var period_modifiers: AttributeEffectModifierArray

## Modifies the [member duration_in_seconds] of other [AttributeEffect]s.
@export var duration_modifiers: AttributeEffectModifierArray

@export_group("Metadata")

## A simple [Dictionary] that can be used to store metadata for effects. Not
## used in any of the Attribute system's internals.
@export var metadata: Dictionary

var _callbacks_by_function: Dictionary = {}

func _init(_id: StringName = "") -> void:
	id = _id
	if Engine.is_editor_hint():
		return
	
	# Callback initialization
	for _function: int in AttributeEffectCallback._Function.values():
		_callbacks_by_function[_function] = []


func _validate_property(property: Dictionary) -> void:
	if property.name == "value_type":
		var exclude: Array = [ValueType.NONE] if must_have_value() else []
		property.hint_string = _format_enum(ValueType, exclude)
		return
	
	if property.name == "value":
		match value_type:
			ValueType.NONE:
				_no_editor(property)
			ValueType.DERIVED_FROM_ATTRIBUTE:
				property.usage = PROPERTY_USAGE_READ_ONLY
		return
	
	if property.name == "value_calculator":
		if !has_value():
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
	
	if property.name == "add_blockers" || property.name == "apply_blockers":
		if !is_blocker():
			_no_editor(property)
		return
	
	if property.name == "value_modifiers" or property.name == "period_modifiers" \
	or property.name == "duration_modifiers":
		if !is_modifier():
			_no_editor(property)
		return


## Helper method for _validate_property.
func _no_editor(property: Dictionary) -> void:
	property.usage = PROPERTY_USAGE_STORAGE


## Helper method for _validate_property.
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
	if Engine.is_editor_hint():
		callback._run_assertions(self)
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


## Applies the [member value_calculator] on the [param attribute_value] and
## [param effect_value], returning the result. It must always be ensured that
## the [param effect_value] comes from [b]this effect[/b], otherwise results
## will be unexpected.
func apply_calculator(attr_base_value: float, attr_current_value: float, effect_value: float) -> float:
	assert_has_value()
	return value_calculator._calculate(attr_base_value, attr_current_value, effect_value)


## Shorthand function to create an [AttributeEffectSpec] for this [AttributeEffect].
## [br]Can be overridden for custom [AttributeEffectSpec] implementations if you know
## what you are doing.
func to_spec() -> AttributeEffectSpec:
	return AttributeEffectSpec.new(self)


## TBD: Make this more verbose?
func _to_string() -> String:
	return "AttributeEffect(id:%s)" % id


##########################################
## Helper functions for feature support ##
##########################################

## Whether or not this effect MUST have [member value].
func must_have_value() -> bool:
	return type == Type.PERMANENT


## Returns true if this effect has a value ([member value])
func has_value() -> bool:
	return value_type != ValueType.NONE


## Asserts [method has_value] returns true.
func assert_has_value() -> void:
	assert(has_value(), "effect does have a value")


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


## TODO
func is_blocker() -> bool:
	return _blocker


## TODO
func is_modifier() -> bool:
	return _modifier


## Whether or not this effect supports [member add_conditions]
func has_add_conditions() -> bool:
	return duration_type != DurationType.INSTANT


## Whether or not this effect supports [member apply_conditions]
func has_apply_conditions() -> bool:
	return has_value()


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


## If this effect is stackable.
func is_stackable() -> bool:
	return stack_mode == AttributeEffect.StackMode.COMBINE
