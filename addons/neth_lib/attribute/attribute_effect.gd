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

## Determines how [member value] is stacked.
enum ValueStackMode {
	## Ignores value when stacking, as if there was only 1 instance of this 
	## [AttributeEffect] applied.
	IGNORE,
	## Multiplies [member value] by [member AttributeEffectSpec.get_stack_count].
	## ie: a stack of 3 would be [member value] * 3.0.
	MULTIPLY_BY_STACK,
	## Divides [member value] by [member AttributeEffectSpec.get_stack_count].
	## ie: a stack of 3 would be [member value] * 3.0.
	DIVIDE_BY_STACK,
}

## Determines how [member duration_in_seconds] is stacked, only applicable if
## [member duration_type] is [enum DurationType.HAS_DURATION].
enum DurationStackMode {
	## Ignores duration during stacking.
	IGNORE,
	## Resets the duration to [member duration_in_seconds].
	RESET,
	## Adds to the existing duration of the [AppliedAttributeEffect].
	ADD,
}

## Determines how [member period_in_seconds] is stacked, only applicable if
## [member duration_type] is NOT [enum DurationType.INSTANT].
enum PeriodStackMode {
	## Ignores period during stacking.
	IGNORE,
	## Multiplies [member period_in_seconds] by the stack count.
	MULTIPLY_BY_STACK,
	## Divides [member period_in_seconds] by the stack count.
	DIVIDE_BY_STACK,
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
		notify_property_list_changed()
		if duration_type != DurationType.HAS_DURATION:
			duration_stack_mode = DurationStackMode.IGNORE
			duration_in_seconds = 0.0

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
		
		if stack_mode != StackMode.COMBINE:
			value_stack_mode = ValueStackMode.IGNORE
			duration_stack_mode = DurationStackMode.IGNORE
		
		notify_property_list_changed()

## How the value is stacked if [member stack_mode] is [enum StackMode.COMBINE].
@export var value_stack_mode: ValueStackMode:
	set(_value):
		value_stack_mode = _value
		notify_property_list_changed()

## How the duration is stacked if [member stack_mode] is [enum StackMode.COMBINE].
@export var duration_stack_mode: DurationStackMode:
	set(_value):
		duration_stack_mode = _value
		notify_property_list_changed()

## How the is stacked if [member stack_mode] is [enum StackMode.COMBINE].
@export var period_stack_mode: PeriodStackMode:
	set(_value):
		period_stack_mode = _value
		notify_property_list_changed()

@export_group("Modifiers")

@export var _modifiers: Array[AttributeEffectModifier]

@export_group("Conditions")

## All [AttributeEffectCondition]s an [Attribute] must meet for this effect to be applied to it.
@export var _default_conditions: Array[AttributeEffectCondition]

var _conditions: Dictionary = {}

func _init(_id: StringName = "") -> void:
	id = _id
	
	# Split conditions up based on block type for efficiency
	for block_type: int in AttributeEffectCondition.BlockType.values():
		_conditions[block_type] = []
	for condition: AttributeEffectCondition in _default_conditions:
		for block_type: AttributeEffectCondition.BlockType in condition.block_types:
			_default_conditions[block_type].append(condition)
	for array: Array in _conditions.values():
		array.sort_custom(AttributeEffectModifier.compare)
	
	# Sort Modifiers
	_modifiers.sort_custom(AttributeEffectModifier.compare)


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
	
	if property.name == "value_stack_mode":
		if stack_mode != StackMode.COMBINE \
		or duration_type == DurationType.INSTANT:
			_no_editor(property)
		return
	
	if property.name == "duration_stack_mode":
		if stack_mode != StackMode.COMBINE \
		or duration_type != DurationType.HAS_DURATION:
			_no_editor(property)
		return
	
	if property.name == "period_stack_mode":
		if stack_mode != StackMode.COMBINE \
		or duration_type == DurationType.INSTANT:
			_no_editor(property)
		return

## Helper method for _validate_property.
func _no_editor(property: Dictionary) -> void:
	property.usage = PROPERTY_USAGE_NO_EDITOR


## Adds the [param modifier] to this [AttributeEffect]. Returns true if it was added,
## false if not (due to [member AttributeEffectModifier.duplicate_instances] being
## false and an instance already existing on this effect.
func add_modifier(modifier: AttributeEffectModifier) -> bool:
	if !modifier.duplicate_instances:
		if _modifiers.has(modifier):
			return false
	_modifiers.append(modifier)
	_modifiers.sort_custom(AttributeEffectModifier.compare)
	return true


## Returns true if this effect has one (or more) instances of [param modifier].
func has_modifier(modifier: AttributeEffectModifier) -> bool:
	return _modifiers.has(modifier)


## Removes the first occrrence of [param modifier], or all occurrences if [param remove_all]
## is true.
func remove_modifier(modifier: AttributeEffectModifier, remove_all: bool = false) -> void:
	_modifiers.erase(modifier)
	if remove_all:
		while _modifiers.has(modifier):
			_modifiers.erase(modifier)


## Returns a new mutable [Array] of all added [AttributeEffectModifier]s. Changes
## to the array are not reflected in this instance.
func get_modifiers() -> Array[AttributeEffectModifier]:
	return _modifiers.duplicate(false)


## Shorthand function to create an [AttributeEffectSpec] for this
## [AttributeEffect]. [param _stack_count] can be specified if
## [member stack_mode] is of type [enum StackMode.COMBINE].
func to_spec(_stack_count: int = 1) -> AttributeEffectSpec:
	assert(_stack_count > 0, "_stack_count (%s) not > 0" % _stack_count)
	assert(stack_mode == StackMode.COMBINE || _stack_count == 1, 
	"_stack_count (%s) > 1 but stack_mode != COMBINE" % _stack_count)
	return AttributeEffectSpec.new(self, _stack_count)


func _get_modified_value(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	var modified_value: float = value
	for modifier: AttributeEffectModifier in _modifiers:
		modified_value = modifier._modify_value(modified_value, attribute, spec)
		if modifier.stop_processing_modifiers:
			break
	return modified_value


## Calculates & returns the new value to assign to [param attribute]'s 
## [member Attribute.value], but does NOT assign the property itself.[br]
## Default implementation first uses the [AttributeEffectModifier]s to modify [member value]
## then uses the [member value_calc_type] to calculate the returned float.[br]
## The returned value should NOT take stacking into account.
func _calculate_value(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(spec._effect == self, "spec._effect (%s) != self" % spec._effect)
	
	var modified_value: float = _get_modified_value(attribute, spec)
	
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
func _calculate_next_period(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(duration_type != DurationType.INSTANT, "duration_type == INSTANT, there is no period")
	
	var modified_period: float = period_in_seconds
	
	for modifier: AttributeEffectModifier in _modifiers:
		modified_period = modifier._modify_next_period(modified_period, attribute, spec)
		if modifier.stop_processing_modifiers:
			break
	
	return modified_period


## Calculates & returns the starting duration to be used right after this effect represented 
## as [param spec] was added to an [param attribute], or when a stack was increased.
## Should NOT modify [param spec] in any way.[br]
## Default implementation uses [member duration_in_seconds] and runs it through every
## [AttributeEffectModifier] in [member modifiers].[br]
## The returned value should NOT take stacking into account.
func _calculate_starting_duration(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(duration_type == DurationType.HAS_DURATION, "duration_type != HAS_DURATION")
	
	var modified_duration: float = duration_in_seconds
	
	for modifier: AttributeEffectModifier in _modifiers:
		modified_duration = modifier._modify_starting_duration(modified_duration, attribute, spec)
		if modifier.stop_processing_modifiers:
			break
	
	return modified_duration


func _to_string() -> String:
	return "AttributeEffect(id:%s)" % id
