## Applicator that multiplies the attribute's value by the effect's value
class_name MultiplyApplicator extends AttributeEffectApplicator

func _get_value_to_set(attribute_value: float, effect_value: float) -> float:
	return attribute_value * effect_value
