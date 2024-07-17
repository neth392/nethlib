## Modifies an [AttributeEffect]'s value, period, or duration.
@tool
class_name AttributeEffectModifier extends Resource

static func sort(a: AttributeEffectModifier, b: AttributeEffectModifier) -> bool:
	if a == null:
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


## Called every time the 
func _modify(current_modified: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return current_modified
