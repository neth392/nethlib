## Calculator that set's the attribute's value to the effect's value,
## "overriding" it.
class_name OverrideCalculator extends AttributeEffectCalculator

func _calculate(attribute_value: float, effect_value: float) -> float:
	return effect_value
