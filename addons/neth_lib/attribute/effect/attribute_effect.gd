## A configurable resource that affects [member Attribute.value].
@tool
class_name AttributeEffect extends Resource

enum AffectedValue {
	## Changes are made permanently to the [member base_value].
	BASE_VALUE,
	CURRENT_VALUE
}

## Short for CalculationType; determines the calculations used when applying
## this [AttributeEffect]'s properties to an [Attribute].
enum ValueCalcType {
	## Adds [member value] to [member Attribute.value] when applied.
	ADD_TO,
	## Subtracts the [member value] from [member Attribute.value] when applied.
	SUBTRACT_FROM,
	## Multiplies [member Attribute.value] by [member value] when applied.
	MULTIPLY_BY,
	## Divides [member Attribute.value] by [member value] when applied.
	DIVIDE_BY,
	## Sets the value of [member Attribute.value] to [member value]. Keep in mind
	## the [member priority] when using this calculation type.
	OVERRIDE,
}

## Determines how this effect can be stacked on an [Attribute], if at all.
enum StackMode {
	## Stacking is not allowed and an assertion will be called
	## if there is an attempt to stack this effect on an [Attribute].
	DENY_ERROR,
	## Stacking is not allowed.
	DENY,
	## Attribute effects are seperate, a new [AppliedAttributeEffect] is created
	## for every instance added to an [Attribute].
	SEPERATE,
	## Attribute effects are combined into one [AppliedAttributeEffect].
	COMBINE,
}

## Determines how the effect is applied time-wise.
enum DurationType {
	## The effect is immediately applied to an [Attribute] and does not remain
	## stored on it.
	INSTANT,
	## The effect is applied to an [Attribute] and remains until it is explicitly
	## removed.
	INFINITE,
	## The effect is applied to an [Attribute] and is removed automatically
	## after [member duration_seconds].
	HAS_DURATION,
}

## The ID of this attribute effect.
@export var id: StringName

## The direct effect to [member Attribute.value]
@export var value: float

## If true, this effect permanently changes the [member Attribute.value] property,
## if false it is just considered in calculations in [method Attribute.get_current_value].
## TODO write this better
@export var permanent_change: bool = false

## The [enum CalcType] that determines how the [member value] is applied to 
## [member Attribute.value].
@export var value_cacl_type: ValueCalcType:
	set(_value):
		value_cacl_type = _value
		notify_property_list_changed()

## The priority to be used to determine the order of execution of [AttributeEffect]s
## on an [Attribute]. Greater priorities will be executed first.
@export var priority: int = 0

## If true, [signal Attribute.effect_added] will be emitted every time an
## [AttributeEffectSpec] of this effect is added to an [Attribute].
@export var emit_added_signal: bool = false

## If true, [signal Attribute.effect_applied] will be emitted every time an
## [AttributeEffectSpec] of this effect is successfully applied on an [Attribute].
@export var emit_applied_signal: bool = false

@export_group("Duration & Period")

## How long the effect lasts.
@export var duration_type: DurationType = DurationType.INSTANT:
	set(_value):
		duration_type = _value
		if duration_type != DurationType.HAS_DURATION:
			duration_in_seconds = 0.0
			if duration_type == DurationType.INSTANT:
				if stack_mode != StackMode.DENY && stack_mode != StackMode.DENY_ERROR:
					stack_mode = StackMode.DENY
				period_in_seconds = 0.0
		notify_property_list_changed()

## The amount of time in seconds this [AttributeEffect] lasts.
@export var duration_in_seconds: float = 0.0:
	set(_value):
		duration_in_seconds = max(0.0, _value)
		notify_property_list_changed()

## Amount of time, in seconds, between when this effect is applied to an [Attribute].[br]
## A zero value means every frame.
@export var period_in_seconds: float = 0.0:
	set(_value):
		period_in_seconds = max(0.0, _value)

@export_group("Stacking")

## The [StackMode] to use when duplicate [AttributeEffect]s are found.
@export var stack_mode: StackMode:
	set(_value):
		stack_mode = _value
		notify_property_list_changed()

@export_group("Conditions")

## All [AttributeEffectCondition]s that must be met for this effect to be
## added to an [Attribute]. This array can safely be directly modified or set.
@export var add_conditions: Array[AttributeEffectCondition]

## All [AttributeEffectCondition]s that must be met for this effect to be
## applied to an [Attribute]. This array can safely be directly modified or set.
@export var apply_conditions: Array[AttributeEffectCondition]

## All [AttributeEffectCondition]s that must be met for this effect to be
## processed (duration, period, etc) on an [Attribute]. This array can 
## safely be directly modified or set.
@export var process_conditions: Array[AttributeEffectCondition]

@export_group("Modifiers")

## Modififiers to modify [member value].
@export var _value_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		_value_modifiers = _value
		_value_modifiers.sort_custom(AttributeEffectModifier.sort)
		_validate_and_assert(_value_modifiers)

## Modififiers to modify [member period_in_seconds].
@export var _period_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		_period_modifiers = _value
		_period_modifiers.sort_custom(AttributeEffectModifier.sort)
		_validate_and_assert(_period_modifiers)

## Modififiers to modify [member duration_in_seconds].
@export var _duration_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		_duration_modifiers = _value
		_duration_modifiers.sort_custom(AttributeEffectModifier.sort)
		_validate_and_assert(_duration_modifiers)

@export_group("Callbacks")

## TODO
@export var _callbacks: Array[AttributeEffectCallback]

var _callbacks_by_function: Dictionary = {}

func _init(_id: StringName = "") -> void:
	id = _id
	
	if Engine.is_editor_hint():
		return
	
	# Callback initialization
	for _function: int in AttributeEffectCallback._Function.values():
		_callbacks_by_function[_function] = []
	
	for callback: AttributeEffectCallback in _callbacks:
		# Adds callbacks to the map that seperates them by which functions each implements
		# This improves efficiency for calling functions as we dont need to call
		# each function on *every callback*, just the callkbacks that implement them
		AttributeEffectCallback._set_functions(callback)
		for _function: AttributeEffectCallback._Function in callback._functions:
			_callbacks_by_function[_function].append(callback)
		# Call the added notifier
		callback._added_to_effect(self)
	
	# Sort Modifiers
	_value_modifiers.sort_custom(AttributeEffectModifier.sort)
	_period_modifiers.sort_custom(AttributeEffectModifier.sort)
	_duration_modifiers.sort_custom(AttributeEffectModifier.sort)


func _validate_property(property: Dictionary) -> void:
	if property.name == "duration_in_seconds":
		if duration_type != DurationType.HAS_DURATION:
			_no_editor(property)
		return
	
	if property.name == "period_in_seconds":
		if duration_type == DurationType.INSTANT:
			_no_editor(property)
		return
	
	if property.name == "stack_mode":
		if duration_type == DurationType.INSTANT:
			_no_editor(property)
		return


func _validate_and_assert(modifiers: Array[AttributeEffectModifier]) -> void:
	for modifier: AttributeEffectModifier in modifiers:
		if modifier != null:
			modifier._validate_and_assert(self)


## Helper method for _validate_property.
func _no_editor(property: Dictionary) -> void:
	property.usage = PROPERTY_USAGE_NO_EDITOR


## Adds the [param callback] from this effect. An assertion is in place to prevent
## multiple [AttributeEffectCallback]s of the same instance being added to an effect.
func add_callback(callback: AttributeEffectCallback) -> void:
	assert(!_callbacks.has(callback), "callback (%s) already exists" % callback)
	AttributeEffectCallback._set_functions(callback)
	_callbacks.append(callback)
	for _function: AttributeEffectCallback._Function in callback._functions:
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
	return _period_modifiers.has(modifier)


## TODO
func has_duration_modifier(modifier: AttributeEffectModifier) -> bool:
	return _duration_modifiers.has(modifier)


## TODO
func remove_value_modifier(modifier: AttributeEffectModifier, remove_all: bool = false) -> void:
	_remove_modifier(modifier, remove_all, _value_modifiers)


## TODO
func remove_period_modifier(modifier: AttributeEffectModifier, remove_all: bool = false) -> void:
	_remove_modifier(modifier, remove_all, _period_modifiers)


## TODO
func remove_duration_modifier(modifier: AttributeEffectModifier, remove_all: bool = false) -> void:
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
	return _period_modifiers.duplicate(false)


func get_duration_modifiers() -> Array[AttributeEffectModifier]:
	return _duration_modifiers.duplicate(false)


## Returns the [member value] after applying all value [AttributeEffectModifier]s to it.
func get_modified_value(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(spec._effect == self, "spec._effect (%s) != self" % spec._effect)
	return _get_modified(value, attribute, spec, _value_modifiers)


## Runs the [param _value] through all [AttributeEffectModifier]s for value.
## Useful for custom logic in modifiers, effects, & conditions.
func modify_value(_value: float, attribute: Attribute, spec: AttributeEffectSpec):
	return _get_modified(_value, attribute, spec, _value_modifiers)


## Applies the [member value_calc_type] to [param attribute_value] and
## [param effect_value], returning the result.
func apply_calc_type(attribute_value: float, effect_value: float) -> float:
	match value_cacl_type:
		ValueCalcType.ADD_TO:
			return attribute_value + effect_value
		ValueCalcType.SUBTRACT_FROM:
			return attribute_value - effect_value
		ValueCalcType.MULTIPLY_BY:
			return attribute_value * effect_value
		ValueCalcType.DIVIDE_BY:
			return attribute_value / effect_value
		ValueCalcType.OVERRIDE:
			return effect_value
		_:
			assert(false, "no calculation written for ValueCalcType=%s" % value_cacl_type)
			return attribute_value


## Returns the [member period_in_seconds] after applying all period [AttributeEffectModifier]s to it.
func get_modified_period(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(spec._effect == self, "spec._effect (%s) != self" % spec._effect)
	assert(duration_type != DurationType.INSTANT, "duration_type == INSTANT, there is no period")
	return _get_modified(period_in_seconds, attribute, spec, _period_modifiers)


## Runs the [param duration_value] through all [AttributeEffectModifier]s for period.
## Useful for custom logic in modifiers, effects, & conditions.
func modify_period_value(period_value: float, attribute: Attribute, spec: AttributeEffectSpec):
	return _get_modified(period_value, attribute, spec, _period_modifiers)


## Returns the [member duration_in_seconds] after applying all duration [AttributeEffectModifier]s to it.
func get_modified_duration(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(spec._effect == self, "spec._effect (%s) != self" % spec._effect)
	assert(duration_type == DurationType.HAS_DURATION, "duration_type != HAS_DURATION")
	return _get_modified(duration_in_seconds, attribute, spec, _duration_modifiers)


## Runs the [param duration_value] through all [AttributeEffectModifier]s for duration.
## Useful for custom logic in modifiers, effects, & conditions.
func modify_duration_value(duration_value: float, attribute: Attribute, spec: AttributeEffectSpec):
	return _get_modified(duration_value, attribute, spec, _duration_modifiers)


## Helper function for the above functions
func _get_modified(to_modify: float, attribute: Attribute, spec: AttributeEffectSpec, 
modifiers: Array[AttributeEffectModifier]) -> float:
	var modified: float = to_modify
	for modifier: AttributeEffectModifier in _value_modifiers:
		modified = modifier._modify(modified, attribute, spec)
		if modifier.stop_processing_modifiers:
			break
	return modified


## Shorthand function to create an [AttributeEffectSpec] for this [AttributeEffect].
func to_spec() -> AttributeEffectSpec:
	return AttributeEffectSpec.new(self)


func _to_string() -> String:
	return "AttributeEffect(id:%s)" % id
