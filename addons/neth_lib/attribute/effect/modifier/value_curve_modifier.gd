## A modifier that allows for an [member AttributeEffect.value]s magnitude
## to be scaled according to the [member curve]. Since [Curve]'s X axis is
## limited from 0 to 1, a [member min] & [member max] OR a [WrappedAttribute]'s id
## can be specified which will multiply 0 by min, & 1 by max for.
@tool
class_name ValueCurveModifier extends AttributeEffectModifier

# TODO this whole class

enum MinMaxValues {
	WRAPPED_ATTRIBUTE,
	STATIC,
}

## The curve to be used. The Y axis is the magnitude
@export var curve: Curve

@export var min: float
@export var max: float

@export var wrapped_attribute_id: StringName

func _modify(value: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	return value
