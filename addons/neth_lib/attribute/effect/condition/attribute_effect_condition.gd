## Abstract class to check if an [Attribute] and [AttributeEffectSpec] meets a condition 
## for the spec to be applied.
@tool
class_name AttributeEffectCondition extends Resource

## A message explaining why this condition has blocked an [AttributeEffect]
## from being applied.
@export_multiline var message: String

## If true, emits the corresponding signal in [Attribute] when this
## condition is not met on an [AttributeEffectSpec]. NOTE: For performance
## reasons, there is no signal for processing being blocked.
@export var emit_blocked_signal: bool = false

## Returns true if the [param attribute] & [param spec] meets the conditions.
func _meets_condition(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	return true
