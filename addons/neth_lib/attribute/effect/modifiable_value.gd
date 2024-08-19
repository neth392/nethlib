## A floating point value member of an [AttributeEffect] that can be modified by
## [AttributeEffectModifier]
class_name ModifiableValue extends Resource

## The value that can be modified by [member modifiers]
@export var value: float

## Any modifiers that should apply to [member value].
@export var modifiers: Array[AttributeEffectModifier]:
	set(_value):
		if OS.is_debug_build():
			_remove_invalid_modifiers(_value)
		if !Engine.is_editor_hint():
			_value.sort_custom(AttributeEffectModifier.sort_descending)
		modifiers = _value
		if Engine.is_editor_hint():
			notify_property_list_changed.call_deferred()

func get_modified_value(attribute: Attribute, spec: AttributeEffectSpec) -> float:
	var modified_value: float = value
	for modifier: AttributeEffectModifier in modifiers:
		if !modifier.should_modify(attribute, spec):
			continue
		modified_value = modifier._modify(value, attribute, spec)
		if modifier.stop_processing_modifiers:
			return modified_value
	
	return modified_value
