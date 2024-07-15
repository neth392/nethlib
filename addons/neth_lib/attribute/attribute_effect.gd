## A configurable resource that applies various effects to an [Attribute].
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
	## Overrides the [member Attribute.value] with [member value] as long as
	## [member override_priority] is the greatest out of all other [AttributeEffect]s
	## who have a value_calc_type of OVERRIDE.
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
	## Adds all of the values of the [AttributeEffect]s of each stacked instance
	## and 
	ADD,
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

## If true, [signal Attribute.effect_processed] will be emitted every time an
## [AttributeEffectSpec
@export var emit_process_signal: bool = false

## The priority to be used in comparing with other [AttributeEffect]s when
## [member value_calc_type] is [enum CalcType.OVERRIDE].
@export var override_priority: int = 0

@export_group("Duration")

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

@export_group("Period")

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

@export var value_stack_mode: ValueStackMode:
	set(_value):
		value_stack_mode = _value
		notify_property_list_changed()

@export var duration_stack_mode: DurationStackMode:
	set(_value):
		duration_stack_mode = _value
		notify_property_list_changed()

@export_group("Modifiers")

@export var _modifiers: Array[AttributeEffectModifier]

@export_group("Conditions")

## All [AttributeEffectCondition]s an [Attribute] must meet for this effect to be applied to it.
@export var conditions: Array[AttributeEffectCondition] = []

func _init(_id: StringName = "") -> void:
	id = _id
	_modifiers.sort_custom(AttributeEffectModifier.compare)


func _validate_property(property: Dictionary) -> void:
	if property.name == "override_priority":
		if value_cacl_type != ValueCalcType.OVERRIDE:
			_no_editor(property)
		return
	
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


## Returns null if this [AttributeEffect] can be applied to the [param attribute],
## or returns the first [AttributeEffectCondition] whose condition was not met.
func can_apply(attribute: Attribute) -> AttributeEffectCondition:
	for condition: AttributeEffectCondition in conditions:
		if condition.block_apply && !condition._meets_condition(attribute):
			return condition
	
	return null


## Returns null if this [AttributeEffect] can be processed on the [param attribute],
## or returns the first [AttributeEffectCondition] whose condition was not met.
func can_process(attribute: Attribute) -> AttributeEffectCondition:
	for condition: AttributeEffectCondition in conditions:
		if condition.block_processing && !condition._meets_condition(attribute):
			return condition
	
	return null


## Shorthand function to create an [AttributeEffectSpec] for this
## [AttributeEffect]. [param _stack_count] can be specified if
## [member stack_mode] is of type [enum StackMode.COMBINE].
func to_spec(_stack_count = 1) -> AttributeEffectSpec:
	assert(_stack_count > 0, "_stack_count (%s) not > 0" % _stack_count)
	assert(stack_mode == StackMode.COMBINE || _stack_count == 1, 
	"_stack_count (%s) > 1 but stack_mode != COMBINE" % _stack_count)
	return AttributeEffectSpec.new(self, _stack_count)


## Called each time this effect represented as [param spec] is triggered on
## [param attribute]. Should not take [param 
func _calculate_value(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(spec.effect == self, "spec.effect (%s) != self" % spec.effect)
	
	var calculated_value: float = value
	
	for modifier: AttributeEffectModifier in _modifiers:
		calculated_value = modifier._modify_value(calculated_value, attribute, spec)
		if modifier.stop_processing_modifiers:
			break
	
	return 0.0


## Calculates the next period to be used right after this effect represented 
## as [param spec] was triggered on [param attribute].
func _calculate_next_period(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(duration_type != DurationType.INSTANT, "duration_type == INSTANT, there is no period")
	
	var calculated_period: float = period_in_seconds
	
	for modifier: AttributeEffectModifier in _modifiers:
		calculated_period = modifier._modify_next_period(calculated_period, attribute, spec)
		if modifier.stop_processing_modifiers:
			break
	
	return calculated_period


## Calculates the starting duration to be used when this effect represented as 
## [param spec] is first applied to [param attribute].
func _calculate_starting_duration(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	assert(duration_type == DurationType.HAS_DURATION, "duration_type != HAS_DURATION, " +\
	"there is no duration")
	
	var calculated_duration: float = duration_in_seconds
	
	for modifier: AttributeEffectModifier in _modifiers:
		calculated_duration = modifier._modify_starting_duration(calculated_duration, attribute, spec)
		if modifier.stop_processing_modifiers:
			break
	
	return calculated_duration


func _to_string() -> String:
	return "AttributeEffect(id:%s)" % id
