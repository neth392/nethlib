## Calculator that multiplies the attribute's value by the effect's value
class_name MultiplyCalculator extends AbstractSimpleCalculator

func _simple_calculate(attribute_value: float, effect_value: float) -> float:
	return attribute_value * effect_value
