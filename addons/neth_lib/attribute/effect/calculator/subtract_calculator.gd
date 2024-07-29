## Calculator that subtracts the effect's value from the attribute's value.
class_name SubtractCalculator extends AbstractSimpleCalculator

func _simple_calculate(attribute_value: float, effect_value: float) -> float:
	return attribute_value - effect_value
