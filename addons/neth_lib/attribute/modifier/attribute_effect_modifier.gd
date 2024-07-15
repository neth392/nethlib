## Modifies an [AttributeEffect]'s calculated values for [member AttributeEffect.value],
## [member AttributeEffect.period_in_seconds], and [member AttributeEffect.duration_in_second]s.
@tool
class_name AttributeEffectModifier extends Resource

static func compare(a: AttributeEffectModifier, b: AttributeEffectModifier) -> bool:
	return a.priority > b.priority

## The priority of processing this [AttributeEffectModifier] in comparison to
## other modifiers.
@export var priority: int = 0

## If true, other [AttributeEffectModifier]s will not be processed after this instance.
@export var stop_processing_modifiers: bool = false

## If true, allow duplicate instances of this modifier on [AttributeEffect]s.
@export var duplicate_instances: bool = false

func _modify_value(current_modified_value: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return current_modified_value


func _modify_next_period(current_modified_period: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return current_modified_period


func _modify_starting_duration(current_modified_duration: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return current_modified_duration
