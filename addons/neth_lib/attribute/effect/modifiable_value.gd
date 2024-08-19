## TODO
class_name ModifiableValue extends Resource

@export var value: float

@export var value_modifiers: AttributeEffectModifierArray = AttributeEffectModifierArray.new()

func get_modified(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return value_modifiers.modify_value(value, attribute, spec)
