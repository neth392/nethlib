## Applicator that set's the attribute's value to the effect's value,
## "overriding" it.
class_name OverrideApplicator extends AttributeEffectApplicator

func _get_value_to_set(attribute_value: float, effect_value: float) -> float:
	return effect_value
