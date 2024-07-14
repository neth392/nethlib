## Abstract class to check if an [Attribute] meets a condition for an
## [AttributeEffect] to be applied to it.
@tool
class_name AttributeEffectCondition extends Resource

## Returns true if the [Attribute] meets this condition.
func _meets_condition(attribute: Attribute) -> bool:
	return true
