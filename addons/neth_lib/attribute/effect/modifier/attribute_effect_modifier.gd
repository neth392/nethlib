## Modifies an [AttributeEffect]'s value, period, or duration.
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

## If true, other [AttributeEffectModifier]s will not be processed after this instance.
@export var stop_processing_modifiers: bool = false

## If true, allow duplicate instances of this modifier on [AttributeEffect]s.
@export var duplicate_instances: bool = false


## Editor tool function that is called when this modifier is added to [param effect].
## A good place to write assertions.
func _validate_and_assert(effect: AttributeEffect) -> void:
	pass


## Called every time the modified property of an [AttributeEffect] is requested.
## [br]NOTE: [param attribute] should NOT be modified here and it's values will reflect
## those from the previous frame as the new calculated values are not set until after all
## effects have been processed on a frame.
func _modify(current_modified: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return current_modified
