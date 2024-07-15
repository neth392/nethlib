## Abstract class to check if an [Attribute] and [AttributeEffectSpec] meets a condition 
## for the spec to be applied.
@tool
class_name AttributeEffectCondition extends Resource

## A message explaining why this condition has blocked an [AttributeEffect]
## from being applied.
@export_multiline var message: String

## If true, if the condition isn't met the [AttributeEffectSpec] can not be
## added to [Attribute] (and therefore not applied). If false,
## the [AttributeEffect] can be added regardless of the condition.
@export var block_add: bool = true

## If true, if the condition isn't met the [AttributeEffectSpec] will not be
## applied to the [Attribute] it is added to. If false, the [AttributeEffect]
## will be processed regardless of condition as long as it is applied to an
## [Attribute].
@export var block_apply: bool = false

## If treu
@export var emit_add_blocked_signal: bool = false

@export var emit_apply_blocked_signal: bool = false

## Returns true if the [param attribute] & [param spec] meets the conditions.
func _meets_condition(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	return true
