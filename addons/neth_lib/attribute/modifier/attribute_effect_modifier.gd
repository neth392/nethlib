## Modifies an [AttributeEffect]'s behavior by providing several overridable functions.
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

## Called each time the [param spec] is processed to calculate which value to apply
## to the [param attribute].
func _modify_value(current_modified_value: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return current_modified_value


func _modify_next_period(current_modified_period: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return current_modified_period


func _modify_starting_duration(current_modified_duration: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return current_modified_duration


## Called when the effect has been succesfully applied to an [Attribute].
func _applied(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


## Called when the effect has been added to an [Attribute].
func _added(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


## Called when the [param spec] has been removed from an [Attribute].
func _removed(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass
