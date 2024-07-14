## A configurable resource that applies various effects to an [Attribute].
@tool
class_name AttributeEffect extends Resource

## Default value for all fields that applies no modification to an [Attribute].
const NO_MODIFIER = 0.0

## Determines how [member value] is stacked.
enum ValueStacking {
	## Ignores value when stacking, as if there was only 1 instance of this 
	## [AttributeEffect] applied.
	IGNORE,
	## Adds all of the values of the [AttributeEffect]s of each stacked instance
	## and 
	ADD,
}

## Determines how [member duration_in_seconds] is stacked, only applicable if
## [member duration_type] is [enum DurationType.HAS_DURATION].
enum DurationStacking {
	## Ignores duration during stacking.
	IGNORE,
	## Resets the duration to [member duration_in_seconds].
	RESET,
	## Adds to the existing duration of the [AppliedAttributeEffect].
	ADD,
}

## Short for CalculationType; determines the calculations used when applying
## this [AttributeEffect]'s properties to an [Attribute].
enum CalcType {
	## Adds to the value of the respective [Attribute] property.
	ADD,
	## Multiplies the base value of the respective [Attribute] property, 
	MULTIPLY_BASE,
	## Overrides the value
	OVERRIDE,
}

## Determines how the effect is applied time-wise.
enum DurationType {
	## The effect is applied to an [Attribute] instantly
	INSTANT,
	## The effect is applied to an [Attribute] and remains until it is explicitly
	## removed.
	INFINITE,
	## The effect is applied to an [Attribute] and is removed automatically
	## after [member duration_seconds].
	HAS_DURATION,
}

## Determines what type of method is used to apply the effect during its [enum DurationType].
enum PeriodType {
	## Effect is applied every x second
	INTERVAL,
	## The period is applied from a [Curve], where the X value is the max
	CURVE,
}

## The ID of this attribute effect.
@export var id: String

## The direct effect to [member Attribute.value]
@export var value: float = NO_MODIFIER

## The [enum CalcType] when applying [member value]
@export var value_cacl_type: CalcType = CalcType.ADD

## The priority to be used in comparing with other [AttributeEffect]s when
## [member value_calc_type] is [enum CalcType.OVERRIDE].
@export var override_priority: int = 0

@export_group("Duration")

## How long the effect lasts.
@export var duration_type: DurationType = DurationType.INSTANT:
	set(_value):
		duration_type = _value
		notify_property_list_changed()
		# TODO  figure out what this did and convert it
		#if !has_duration && stack_mode == StackMode.ADD_DURATION:
			#stack_mode = StackMode.DENY

## The amount of time in seconds this [AttributeEffect] lasts.
@export var duration_in_seconds: float = 0.0:
	set(_value):
		duration_in_seconds = max(0.0, _value)
		notify_property_list_changed()

@export_group("Period")

@export var period_type: PeriodType

## Amount of time inbetween when this effect activates. Only relevant for [member value].
@export var period_in_seconds: float = 0.0

@export var period_curve: Curve = Curve.new()

@export_group("Stacking")

## If true, this [AttributeEffect] can be stacked.
@export var stackable: bool = false

## The [StackMode] to use when duplicate [AttributeEffect]s are found.
@export var stack_mode: StackMode = StackMode.REPLACE

@export_group("Conditions")

## If true, conditions are enabled to determine when this effect can apply to an [Attribute].
##  Set to false if there are no conditions configured for better performance.
@export var enable_conditions: bool = false:
	set(_value):
		enable_conditions = _value
		notify_property_list_changed()

## All [AttributeEffectCondition]s an [Attribute] must meet for this effect to be applied to it.
@export var conditions: Array[AttributeEffectCondition] = []

func _init(_id: String = "") -> void:
	id = _id


func _validate_property(property: Dictionary) -> void:
	if property.name == "duration" && duration_type != DurationType.HAS_DURATION:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		return
	
	if duration_type == DurationType.INSTANT && AttributeUtil.instant_exclusion_props.has(property.name):
		property.usage = PROPERTY_USAGE_NO_EDITOR
		return
	
	if !enable_conditions && AttributeUtil.condition_properties.has(property.name):
		property.usage = PROPERTY_USAGE_NO_EDITOR
		return
	
	#if property.name == "stack_mode":
		#property.hint = PROPERTY_HINT_ENUM
		#property.hint_string = ""
		#for name: String in StackMode.keys():
			#if !has_duration && name == "ADD_DURATION":
				#continue
			#var prefix: String = "" if property.hint_string.is_empty() else ","
			#property.hint_string += prefix + name.capitalize() + ":" + str(StackMode[name])


## Returns null if this [AttributeEffect] can be applied to the specified [Attribute],
## or returns the first [AttributeEffectCondition] whose condition was not met.
func can_apply(attribute: Attribute) -> AttributeEffectCondition:
	
	if enable_conditions:
		for condition: AttributeEffectCondition in conditions:
			if !condition._meets_condition(attribute):
				return condition
	
	return null


func _to_string() -> String:
	return ObjectUtil.to_string_helper("AttributeEffect", self)
