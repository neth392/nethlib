## Calculator that set's the attribute's value to the effect's value, "overriding" it.
class_name OverrideCalculator extends AttributeEffectCalculator

func _calculate(attr_base_value: float, attr_current_value: float, effect_value: float) -> float:
	return effect_value
