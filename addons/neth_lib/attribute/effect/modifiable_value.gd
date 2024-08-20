## Represents a floating point value of [AttributeEffect] that can be modified by
## [AttributeEffectModifier]s.
class_name ModifiableValue extends Resource

## The floating point value
@export var value: float

## Any [AttributeEffectModifier]s that can apply to the value.
@export var value_modifiers: AttributeEffectModifierArray = AttributeEffectModifierArray.new()


## Returns [member value] modified by [member value_modifiers].
func get_modified(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return value_modifiers.modify_value(value, attribute, spec)
