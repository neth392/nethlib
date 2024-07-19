class_name BaseValueApplicator extends AttributeEffectApplicator


func _apply(attribute: Attribute, effect_value: float) -> void:
	attribute.base_value = _get_value_to_set(attribute.base_value, effect_value)


func _get_value_to_set(attribute_base_value: float, effect_value: float) -> float:
	assert(false, "_get_value_to_set not implemented")
	return 0.0
