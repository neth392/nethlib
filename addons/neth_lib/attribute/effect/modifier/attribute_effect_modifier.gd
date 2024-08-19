## Modifies an [AttributeEffect]'s generated value, period, or duration. Does NOT
## change any value on an [AttributeEffectSpec], such as remaining_duration or remaining_period.
## For instant changes to those values, pair a modifier with an [AttributeEffectCallback].
@tool
class_name AttributeEffectModifier extends Resource

## For use in [method Array.sort_custom], returns a bool so that the modifier with
## the greater priority is in front of the other in the array (descending order)
static func sort_descending(a: AttributeEffectModifier, b: AttributeEffectModifier) -> bool:
	if a == null: # Null checks here for usage in editor (sometimes a null element is present)
		return false
	if b == null:
		return true
	return a.priority > b.priority

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
	if conditions.is_empty():
		return true
	for condition: AttributeEffectCondition in conditions:
		if !condition.meets_condition(attribute, spec):
			return false
	return true


## Editor tool function that is called when this modifier is added to [param effect].
## Returns false if it can be added to the [param effect], false if not. Should ideally
## push a warning to console as to why it can't be added.
func _validate_and_warn(effect: AttributeEffect) -> bool:
	return true


## Must be implemented to modify the [param value] based on the context of [param attribute]
## and [param spec]. Must return the modified value, or can return the [param value]
## the leave it "unmodified".
## [br]NOTE: [param attribute] should NOT be modified here and it's values will reflect
## those from the previous frame as the new calculated values are not set until after all
## effects have been processed on a frame.
func _modify(value: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return value
