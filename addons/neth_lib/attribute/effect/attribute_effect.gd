## A configurable resource that affects [member Attribute.value].
@tool
class_name AttributeEffect extends Resource

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

@export_group("Modifiers")

## Modififiers to modify [member value].
@export var _value_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		_value_modifiers = _value
		if _value_modifiers != null:
			_value_modifiers.sort_custom(AttributeEffectModifier.sort)

## Modififiers to modify [member period_in_seconds].
@export var _period_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		_period_modifiers = _value
		if _period_modifiers != null:
			_period_modifiers.sort_custom(AttributeEffectModifier.sort)

## Modififiers to modify [member duration_in_seconds].
@export var _duration_modifiers: Array[AttributeEffectModifier]:
	set(_value):
		_period_modifiers = _value
		if _period_modifiers != null:
			_period_modifiers.sort_custom(AttributeEffectModifier.sort)

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

@export_group("Callbacks")

## TODO
@export var _callbacks: Array[AttributeEffectCallback]

var _callbacks_by_function: Dictionary = {}

func _init(_id: StringName = "") -> void:
	id = _id
	
	if Engine.is_editor_hint():
		return
	
	for _function: int in AttributeEffectCallback._Function.values():
		_callbacks_by_function[_function] = []
	
	for callback: AttributeEffectCallback in _callbacks:
		AttributeEffectCallback._set_functions(callback)
		for _function: AttributeEffectCallback._Function in callback._functions:
			_callbacks_by_function[_function].append(callback)
	
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


## Helper method for _validate_property.
func _no_editor(property: Dictionary) -> void:
	property.usage = PROPERTY_USAGE_NO_EDITOR

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
	if !modifier.duplicate_instances:
		if array.has(modifier):
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


## Shorthand function to create an [AttributeEffectSpec] for this [AttributeEffect].
func to_spec() -> AttributeEffectSpec:
	return AttributeEffectSpec.new(self)


func _get_modified_value(to_modify: float, attribute: Attribute, spec: AttributeEffectSpec, 
modifiers: Array[AttributeEffectModifier]) -> float:
	var modified: float = to_modify
	for modifier: AttributeEffectModifier in _value_modifiers:
		modified = modifier._modify(modified, attribute, spec)
		if modifier.stop_processing_modifiers:
			break
	return modified


## Calculates & returns the new value to assign to [param attribute]'s 
## [member Attribute.value], but does NOT assign the property itself.[br]
## Default implementation first uses the [AttributeEffectModifier]s to modify [member value]
## then uses the [member value_calc_type] to calculate the returned float.[br]
## The returned value should NOT take stacking into account.
func calculate_value(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(spec._effect == self, "spec._effect (%s) != self" % spec._effect)
	
	var modified_value: float = _get_modified_value(value, attribute, spec, 
	_value_modifiers)
	
	match value_cacl_type:
		ValueCalcType.ADD_TO:
			return attribute.value + modified_value
		ValueCalcType.SUBTRACT_FROM:
			return attribute.value - modified_value
		ValueCalcType.MULTIPLY_BY:
			return attribute.value * modified_value
		ValueCalcType.DIVIDE_BY:
			return attribute.value / modified_value
		ValueCalcType.OVERRIDE:
			return modified_value
		_:
			assert(false, "no calculation written for ValueCalcType=%s" % value_cacl_type)
			return attribute.value


## Calculates & returns the next period to be used right after this effect represented 
## as [param spec] was triggered on [param attribute]. Does NOT set
## [member AttributeEffectSpec.remaining_period].[br]
## Default implementation uses [member period_in_seconds] and runs it through every
## [AttributeEffectModifier] in [member modifiers].[br]
## The returned value should NOT take stacking into account.
func calculate_next_period(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(duration_type != DurationType.INSTANT, "duration_type == INSTANT, there is no period")
	return _get_modified_value(period_in_seconds, attribute, spec, _period_modifiers)


## Calculates & returns the starting duration to be used right after this effect represented 
## as [param spec] was added to an [param attribute], or when a stack was increased.
## Should NOT modify [param spec] in any way.[br]
## Default implementation uses [member duration_in_seconds] and runs it through every
## [AttributeEffectModifier] in [member modifiers].[br]
## The returned value should NOT take stacking into account.
func calculate_starting_duration(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(duration_type == DurationType.HAS_DURATION, "duration_type != HAS_DURATION")
	return _get_modified_value(duration_in_seconds, attribute, spec, _duration_modifiers)


func _to_string() -> String:
	return "AttributeEffect(id:%s)" % id
