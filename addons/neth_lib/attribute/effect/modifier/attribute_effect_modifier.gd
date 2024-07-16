## Modifies an [AttributeEffect]'s value, period, and duration.
@tool
class_name AttributeEffectModifier extends Resource

static func compare(a: AttributeEffectModifier, b: AttributeEffectModifier) -> bool:
	return a.priority > b.priority

## The priority of processing this [AttributeEffectModifier] in comparison to
## other modifiers. Greater priorities are processed first.
@export var priority: int = 0

## If true, other [AttributeEffectModifier]s will not be processed after this instance.
@export var stop_processing_modifiers: bool = false

## If true, allow duplicate instances of this modifier on [AttributeEffect]s.
@export var duplicate_instances: bool = false


## Called every time the 
func _modify_value(current_modified: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return current_modified
