## Applicator that subtracts the effect's value from the attribute's value.
class_name SubtractApplicator extends AttributeEffectApplicator

func _get_value_to_set(attribute_value: float, effect_value: float) -> float:
	return attribute_value - effect_value
