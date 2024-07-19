## Responsible for applying an [AttributeEffect]'s resultant value to an [Attribute].
@tool
class_name AttributeEffectApplicator extends Resource


## Called when this applicator is set to the [param effect]. A good place
## to call assertions to prevent applicators being applied to effects they may
## not play nicely with. Also called any time a property of [param effect] is modified.
## Only called while in the editor or when the game is running in debug mode.
func _validate_and_assert(effect: AttributeEffect) -> void:
	pass


## Applies the [param effect_value] to the [param attribute].
func _apply(attribute: Attribute, effect_value: float) -> void:
	assert(false, "_apply not implemented")
