## Abstract class to check if an [Attribute] and [AttributeEffectSpec] meets a condition 
## for the spec to be applied.
@tool
class_name AttributeEffectCondition extends Resource

## A message explaining why this condition has blocked an [AttributeEffect]
## from being applied.
@export_multiline var message: String

## If true, if the condition isn't met the [AttributeEffect] is blocked when
## it is attempted to be applied in [method Attribute.apply_effect]. If false,
## the [AttributeEffect] can be applied regardless of the condition.
@export var block_apply: bool = true

## If true, if the condition isn't met the [AttributeEffect] will not be
## processed when it is applied to an [Attribute]. If false, the [AttributeEffect]
## will be processed regardless of condition as long as it is applied to an
## [Attribute].
@export var block_processing: bool = false

## Returns true if the [param attribute] & [param spec] meets the conditions.
func _meets_condition(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	return true
