## Modifies an [AttributeEffect]'s generated value, period, or duration. Does NOT
## change any value on an [AttributeEffectSpec], such as remaining_duration or remaining_period.
## For instant changes to those values, pair a modifier with an [AttributeEffectCallback].
@tool
class_name AttributeEffectModifier extends Resource

## The priority of processing this [AttributeEffectModifier] in comparison to
## other modifiers. Greater priorities are processed first.
@export var priority: int = 0

## If true, other [AttributeEffectModifier]s of the same [AttributeEffect] will not be processed
## after this instance. Does not prevent modifiers from effects that act as modifiers
## of other effects from applying.
@export var stop_processing_modifiers: bool = false

## If true, allow duplicate instances of this modifier on [AttributeEffect]s.
@export var duplicate_instances: bool = false

## Conditions that must be met for this modifier to modify an [AttributeEffectSpec].
@export var conditions: Array[AttributeEffectCondition]


## Tests the [member should_modify_conditions] against the [param attribute] and
## [param spec], returning true if there are no conditions or all conditions are met,
## false if not.
func should_modify(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	for condition: AttributeEffectCondition in conditions:
		if !condition.meets_condition(attribute, spec):
			return false
	return true


## Must be implemented to modify the [param value] based on the context of [param attribute]
## and [param spec]. Must return the modified value, or can return the [param value]
## the leave it "unmodified".
## [br]NOTE: The context parameters, [param attribute] and [param spec] should NOT be modified here.
func _modify(value: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return value
