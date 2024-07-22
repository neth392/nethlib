## Responsible for applying an [AttributeEffect]'s resultant value to an [Attribute].
@tool
class_name AttributeEffectApplicator extends Resource


## Called when this applicator is set to the [param effect]. A good place
## to call assertions to prevent applicators being applied to effects they may
## not play nicely with. Also called any time a property of [param effect] is modified.
## Only called while in the editor or when the game is running in debug mode.
func _validate_and_assert(effect: AttributeEffect) -> void:
	pass


## Must be overridden to return the value to be set to an [Attribute].
## [br][param attribute_value] is the current value of the [Attribute], either 
## [member Attribute.base_value] or [member Attribute._current_value], depending
## on the [member AttributeEffect.type]
## [br] [member effect_value] is the value derived from the [AttributeEffect].
## [br]The returned value will be set in place of the current [param attribute_value].
func _get_value_to_set(attribute_value: float, effect_value: float) -> float:
	assert(false, "_get_value_to_set not implemented")
	return 0.0
