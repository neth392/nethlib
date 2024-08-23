## Overrides an [AttributeEffect]'s value with the value of an [Attribute].
class_name DerivedModifier extends AttributeEffectModifier

## The value to use of the [Attribute].
@export var value_to_use: Attribute.Value

var _attribute: Attribute

func _modify(value: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return value
