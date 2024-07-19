class_name CurrentValueApplicator extends AttributeEffectApplicator


func _apply(attribute: Attribute, effect_value: float) -> void:
	attribute._current_value = _get_value_to_set(attribute._current_value, effect_value)


func _get_value_to_set(attribute_current_value: float, effect_value: float) -> float:
	assert(false, "_get_value_to_set not implemented")
	return 0.0
