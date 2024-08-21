## Abstract class to check if an [Attribute] and [AttributeEffectSpec] meets a condition 
## for the spec to be applied.
## [br]Some useful considerations when designing your own conditions:
## [br] - [method AttributeEffectSpec.get_pending_value] can be used to determine if
## the spec should apply based on it's potential value. TODO FIX THIS NOTE
@tool
class_name AttributeEffectCondition extends Resource

## A message explaining why this condition has blocked an [AttributeEffect]
## from being applied.
@export_multiline var message: String

## If true, emits the corresponding signal in [Attribute] when this
## condition is not met on an [AttributeEffectSpec]. NOTE: For performance
## reasons, there is no signal for processing being blocked.
@export var emit_blocked_signal: bool = false

## If true, the condition result is negated.
@export var negate: bool = false


## Tests that the [param attribute] & [param spec] meets this condition.
## [br]WARNING: Do NOT override this.
func meets_condition(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	var meets: bool = _meets_condition(attribute, spec)
	if negate:
		return !meets
	return meets


## Returns true if the [param attribute] & [param spec] meets the conditions. Should NOT
## modify the attribute or spec at all.
## [br]NOTE: OVERRIDE THIS
func _meets_condition(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	return true
