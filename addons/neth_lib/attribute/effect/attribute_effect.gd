## A configurable resource that affects [member Attribute.value].
@tool
class_name AttributeEffect extends Resource

## The type of effect.
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
	## Attribute effects are seperate, a new [AppliedAttributeEffect] is created
	## for every instance added to an [Attribute].
	SEPERATE = 2,
	## Attribute effects are combined into one [AppliedAttributeEffect].
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

## The type of effect, see [enum AttributeEffect.Type]
@export var type: Type = Type.PERMANENT:
	set(_value):
		type = _value
		match type:
			Type.TEMPORARY:
				# INSTANT not compatible with TEMPORARY
				if duration_type == DurationType.INSTANT:
					duration_type = DurationType.INFINITE
			Type.PERMANENT:
				pass # TODO remove this statement if not needed
			_:
				assert(false, "no implementation written for type %s" % type)
		notify_property_list_changed()

## The direct effect to [member Attribute.value]
@export var value: float

## Determines how the effect is applied to an [Attribute] (i.e. added, multiplied, etc).
@export var value_calculator: AttributeEffectCalculator

## The priority to be used to determine the order when applying [AttributeEffect]s
## on an [Attribute]. Greater priorities will be applied first. One example; if you want an
## effect to override a value on an attribute & not have that value modified by any other effects,
## then the priority should be lesser than other effects that can be applied so the override
## effect is applied last.
## [br]NOTE: Effects of [enum Type.PERMANENT] are processed BEFORE ALL effects of 
## [enum Type.TEMPORARY], despite priority.
## [br]NOTE: Priority is not used in processing of period & duration.
@export var apply_priority: int = 0

@export_group("Signals")

## If true, [signal Attribute.effect_added] will be emitted every time an
## [AttributeEffectSpec] of this effect is added to an [Attribute].
@export var emit_added_signal: bool = false

## If true, [signal Attribute.effect_applied] will be emitted every time an
## [AttributeEffectSpec] of this effect is successfully applied on an [Attribute].
## [br]NOTE: ONLY AVAILABLE FOR [enum Type.PERMANENT].
@export var emit_applied_signal: bool = false

## If true, [signal Attribute.effect_removed] will be emitted every time an
## [AttributeEffectSpec] of this effect is removed from an [Attribute].
@export var emit_removed_signal: bool = false

@export_group("Duration")

## How long the effect lasts.
@export var duration_type: DurationType:
	set(_value):
		if type == Type.TEMPORARY && _value == DurationType.INSTANT:
			duration_type = DurationType.INFINITE
			return
		duration_type = _value
		if duration_type == DurationType.INSTANT:
			if stack_mode != StackMode.DENY && stack_mode != StackMode.DENY_ERROR:
				stack_mode = StackMode.DENY
		notify_property_list_changed()

## The amount of time in seconds this [AttributeEffect] lasts.
@export var duration_in_seconds: float = 0.0:
	set(_value):
		duration_in_seconds = max(0.0, _value)
		notify_property_list_changed()

@export_group("Period")

## Amount of time, in seconds, between when this effect is applied to an [Attribute].
## [br]Zero or less means every frame.
## [br]NOTE: ONLY AVAILABLE FOR [enum Type.PERMANENT].
@export var period_in_seconds: float = 0.0:
	set(_value):
		period_in_seconds = max(0.0, _value)

## If [member period_in_seconds] should apply as a "delay" between when this effect 
## is added to an [Attribute] and its first time applying.
## [br]NOTE: ONLY AVAILABLE FOR [enum Type.PERMANENT].
@export var initial_period: bool = false

@export_group("Stacking")

## The [StackMode] to use when duplicate [AttributeEffect]s are found.
@export var stack_mode: StackMode:
	set(_value):
		if duration_type == DurationType.INSTANT && _value == StackMode.COMBINE:
			stack_mode = StackMode.DENY
			return
		stack_mode = _value
		notify_property_list_changed()

@export_group("Conditions")

## All [AttributeEffectCondition]s that must be met for this effect to be
## added to an [Attribute]. This array can safely be directly modified or set.
@export var add_conditions: Array[AttributeEffectCondition]

## All [AttributeEffectCondition]s that must be met for this effect to be
## applied to an [Attribute]. This array can safely be directly modified or set.[br]
## [br]NOTE: Only for [enum Type.PERMANENT] effects, as TEMPORARY effects are [b]always[/b]
## applied if the effect was added.
## [br]TBD: Decide if temporary effects should have apply conditions.
@export var apply_conditions: Array[AttributeEffectCondition]

## All [AttributeEffectCondition]s that must be met for this effect to be
## processed (duration, period, etc) on an [Attribute]. This array can 
## safely be directly modified or set.
## [br]NOTE: Only for [enum Type.PERMANENT] effects as TEMPORARY effects are
## always processing.
@export var process_conditions: Array[AttributeEffectCondition]

@export_group("Modifiers")

## Modififiers to modify [member value].
## [br]NOTE: Be careful when using these with TEMPORARY effects. They are 
## not called in a scheduled manner so it could result in unpredictable
## values being set.
@export var _value_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		_value_modifiers = _value
		_value_modifiers.sort_custom(AttributeEffectModifier.sort_descending)
		_validate_and_assert(_value_modifiers)

## Modififiers to modify [member period_in_seconds].
## NOTE: Only for [enum Type.PERMANENT] effects.
@export var _period_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		_period_modifiers = _value
		_period_modifiers.sort_custom(AttributeEffectModifier.sort_descending)
		_validate_and_assert(_period_modifiers)

## Modififiers to modify [member duration_in_seconds].
@export var _duration_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		_duration_modifiers = _value
		_duration_modifiers.sort_custom(AttributeEffectModifier.sort_descending)
		_validate_and_assert(_duration_modifiers)

@export_group("Callbacks")

## List of [AttributeEffectCallback]s to extend the functionality of this effect
## further than modifying the value of an [Attribute].
@export var _callbacks: Array[AttributeEffectCallback]

var _callbacks_by_function: Dictionary = {}

func _init(_id: StringName = "") -> void:
	id = _id
	
	if Engine.is_editor_hint():
		return
	
	# Callback initialization
	for _function: int in AttributeEffectCallback._Function.values():
		_callbacks_by_function[_function] = []
	
	# Register default callbacks
	for callback: AttributeEffectCallback in _callbacks:
		_add_callback_internal(callback, false)
	
	# Sort Modifiers
	_value_modifiers.sort_custom(AttributeEffectModifier.sort_descending)
	_validate_and_assert(_value_modifiers)
	if has_period():
		_period_modifiers.sort_custom(AttributeEffectModifier.sort_descending)
		_validate_and_assert(_period_modifiers)
	if has_duration():
		_duration_modifiers.sort_custom(AttributeEffectModifier.sort_descending)
		_validate_and_assert(_duration_modifiers)


func _validate_property(property: Dictionary) -> void:
	
	if property.name == "emit_applied_signal":
		if !can_emit_apply_signal():
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
	
	if property.name == "period_in_seconds" || property.name == "initial_period":
		if !has_period():
			_no_editor(property)
		return
	
	if property.name == "stack_mode":
		if is_instant():
			_no_editor(property)
		return
	
	if property.name == "apply_conditions":
		if !has_apply_conditions():
			_no_editor(property)
		return
	
	if property.name == "process_conditions":
		if !has_process_conditions():
			_no_editor(property)
		return
	
	if property.name == "_period_modifiers":
		if !has_period():
			_no_editor(property)
		return
	
	if property.name == "_duration_modifiers":
		if !has_duration():
			_no_editor(property)


func _validate_and_assert(modifiers: Array[AttributeEffectModifier]) -> void:
	if OS.is_debug_build():
		for modifier: AttributeEffectModifier in modifiers:
			if modifier != null:
				modifier._validate_and_assert(self)


## Helper method for _validate_property.
func _no_editor(property: Dictionary) -> void:
	property.usage = PROPERTY_USAGE_NO_EDITOR


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


## TODO
func add_value_modifier(modifier: AttributeEffectModifier) -> bool:
	return _add_modifier(modifier, _value_modifiers)


## TODO
func add_period_modifier(modifier: AttributeEffectModifier) -> bool:
	return _add_modifier(modifier, _period_modifiers)


## TODO
func add_duration_modifier(modifier: AttributeEffectModifier) -> bool:
	return _add_modifier(modifier, _duration_modifiers)


## TODO
func _add_modifier(modifier: AttributeEffectModifier, array: Array[AttributeEffectModifier]) -> bool:
	assert(modifier != null, "modifier is null")
	if OS.is_debug_build():
		modifier.validate_and_assert(self)
	
	if !modifier.duplicate_instances && array.has(modifier):
		return false
	
	var insert_index: int = 0
	for index: int in array.size():
		if modifier.priority > array[index].priority:
			insert_index = index
			break
	
	array.insert(insert_index, modifier)
	return true


## TODO
func has_value_modifier(modifier: AttributeEffectModifier) -> bool:
	return _value_modifiers.has(modifier)


## TODO
func has_period_modifier(modifier: AttributeEffectModifier) -> bool:
	assert_has_period()
	return _period_modifiers.has(modifier)


## TODO
func has_duration_modifier(modifier: AttributeEffectModifier) -> bool:
	assert_has_duration()
	return _duration_modifiers.has(modifier)


## TODO
func remove_value_modifier(modifier: AttributeEffectModifier, remove_all: bool = false) -> void:
	_remove_modifier(modifier, remove_all, _value_modifiers)


## TODO
func remove_period_modifier(modifier: AttributeEffectModifier, remove_all: bool = false) -> void:
	assert_has_period()
	_remove_modifier(modifier, remove_all, _period_modifiers)


## TODO
func remove_duration_modifier(modifier: AttributeEffectModifier, remove_all: bool = false) -> void:
	assert_has_duration()
	_remove_modifier(modifier, remove_all, _duration_modifiers)


func _remove_modifier(modifier: AttributeEffectModifier, remove_all: bool,
array: Array[AttributeEffectModifier]) -> void:
	array.erase(modifier)
	if remove_all:
		while array.has(modifier):
			array.erase(modifier)


## TODO
func get_value_modifiers() -> Array[AttributeEffectModifier]:
	return _value_modifiers.duplicate(false)


func get_period_modifiers() -> Array[AttributeEffectModifier]:
	assert_has_period()
	return _period_modifiers.duplicate(false)


func get_duration_modifiers() -> Array[AttributeEffectModifier]:
	assert_has_duration()
	return _duration_modifiers.duplicate(false)


## Returns the [member value] after applying all value [AttributeEffectModifier]s to it.
func get_modified_value(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return modify_value(value, attribute, spec)


## Runs the [param _value] through all [AttributeEffectModifier]s for value.
## Useful for custom logic in modifiers, effects, & conditions.
func modify_value(_value: float, attribute: Attribute, spec: AttributeEffectSpec):
	return _get_modified(_value, attribute, spec, _value_modifiers)


## Applies the [member value_calculator] on the [param attribute_value] and
## [param effect_value], returning the result. It must always be ensured that
## the [param effect_value] comes from [b]this effect[/b], otherwise results
## will be unexpected.
func apply_calculator(attr_base_value: float, attr_current_value: float, effect_value: float) -> float:
	return value_calculator._calculate(attr_base_value, attr_current_value, effect_value)


## Returns the [member period_in_seconds] after applying all period [AttributeEffectModifier]s to it.
func get_modified_period(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert_has_period()
	return modify_period_value(period_in_seconds, attribute, spec)


## Runs the [param duration_value] through all [AttributeEffectModifier]s for period.
## Useful for custom logic in modifiers, effects, & conditions.
func modify_period_value(period_value: float, attribute: Attribute, spec: AttributeEffectSpec):
	assert_has_period()
	return _get_modified(period_value, attribute, spec, _period_modifiers)


## Returns the [member duration_in_seconds] after applying all duration [AttributeEffectModifier]s to it.
func get_modified_duration(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert_has_duration()
	return modify_duration_value(duration_in_seconds, attribute, spec)


## Runs the [param duration_value] through all [AttributeEffectModifier]s for duration.
## Useful for custom logic in modifiers, effects, & conditions.
func modify_duration_value(duration_value: float, attribute: Attribute, spec: AttributeEffectSpec):
	assert_has_duration()
	return _get_modified(duration_value, attribute, spec, _duration_modifiers)


## Helper function for the above functions
func _get_modified(to_modify: float, attribute: Attribute, spec: AttributeEffectSpec, 
modifiers: Array[AttributeEffectModifier]) -> float:
	assert_spec_is_self(spec)
	var modified: float = to_modify
	for modifier: AttributeEffectModifier in _value_modifiers:
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


## Returns true if this effect supports a [member duration_type] of 
## [enum DurationType.INSTANT].
func can_be_instant() -> bool:
	return type == Type.PERMANENT


## Whether or not this effect supports having apply [AttributeEffectCondition]s.
func has_apply_conditions() -> bool:
	return type == Type.PERMANENT


## [method assert]s that [method has_apply_conditions] is true.
func assert_has_apply_conditions() -> void:
	assert(has_process_conditions, "effect does not have apply conditions")


## Whether or not this effect supports having process [AttributeEffectCondition]s.
func has_process_conditions() -> bool:
	return type == Type.PERMANENT && duration_type != DurationType.INSTANT


## [method assert]s that [method has_process_conditions] is true.
func assert_has_process_conditions() -> void:
	assert(has_process_conditions, "effect does not have process conditions")


## Whether or not this effect can emit [signal Attribute.effect_applied].
func can_emit_apply_signal() -> bool:
	return type == Type.PERMANENT


## Returns true if this effect has a [member duration_in_seconds].
func has_duration() -> bool:
	return duration_type == DurationType.HAS_DURATION


## [method assert]s that [method has_duration] is true.
func assert_has_duration() -> void:
	assert(has_duration(), "effect does not have a duration_in_seconds")


## Returns true if this effect has a [member period_in_seconds].
func has_period() -> bool:
	return type == Type.PERMANENT && !is_instant()


## [method has_period]s that [method has_duration] is true.
func assert_has_period() -> void:
	assert(has_period(), "effect does not have a period_in_seconds")


## [method assert]s that [member AttributeEffectSpec._effect] for [param spec]
## is equal to this instance.
func assert_spec_is_self(spec: AttributeEffectSpec) -> void:
	assert(spec._effect == self, "self != spec._effect (%s)" % spec._effect)
