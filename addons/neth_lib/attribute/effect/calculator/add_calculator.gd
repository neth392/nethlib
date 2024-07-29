## Calculator that adds the effect's value to the attribute's value.
class_name AddCalculator extends AbstractSimpleCalculator

func _simple_calculate(attribute_value: float, effect_value: float) -> float:
	return attribute_value + effect_value
