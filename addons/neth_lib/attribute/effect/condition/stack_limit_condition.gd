## Condition that when used as an "add" condition, will block the stacking of specs
## beyond a configured limit.
class_name StackLimitCondition extends AttributeEffectCondition

## The maximum stack count, inclusive.
@export var stack_limit: int

## Returns true if the [param attribute] & [param spec] meets the conditions. Should NOT
## modify the attribute or spec at all.
func _meets_condition(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	return spec.get_stack_count() < stack_limit
