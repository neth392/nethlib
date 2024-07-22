## Applicator that adds the effect's value to the attribute's value.
class_name AddApplicator extends AttributeEffectApplicator

func _get_value_to_set(attribute_value: float, effect_value: float) -> float:
	return attribute_value + effect_value
