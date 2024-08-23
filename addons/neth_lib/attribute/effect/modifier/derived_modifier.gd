## Overrides an [AttributeEffect]'s value with the value of an [Attribute] from the
## [method AttributeEffectSpec.get_source]
class_name DerivedModifier extends AttributeEffectModifier

## The ID of the attribute
@export var attribute_id: StringName

## The value to use of the [Attribute].
@export var value_to_use: Attribute.Value

func _modify(value: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return value
