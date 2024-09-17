## Represents a floating point value of [AttributeEffect] that can be modified by
## [AttributeEffectModifier]s.
class_name ModifiableValue extends Resource

enum ValueType {
	STATIC,
	ATTRIBUTE_BASE_VALUE,
	ATTRIBUTE_CURRENT_VALUE,
}

@export var type: ValueType

## The floating point value
@export var _value: float:
	get():
		match type:
			ValueType.STATIC:
				return _value
		if type == ValueType.STATIC:
			return value
		return 0.0 # TODO return attribute value

## Any [AttributeEffectModifier]s that can apply to the value.
@export var value_modifiers: AttributeEffectModifierArray = AttributeEffectModifierArray.new()

## Returns [member value] modified by [member value_modifiers].
func get_modified(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return value_modifiers.modify_value(_value, attribute, spec)
