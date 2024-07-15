@tool
class_name AttributeEffectValueCurveModifier extends AttributeEffectModifier

enum MinMaxValues {
	WRAPPED_ATTRIBUTE,
	STATIC,
}

@export var curve: Curve

@export var min: float
@export var max: float

@export var wrapped_attribute_id: StringName

func _modify_value(current_modified_value: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return current_modified_value
