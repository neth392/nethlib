## Responsible for calculating how to apply an [AttributeEffect]'s resultant value 
## to an [Attribute].
@tool
class_name AttributeEffectCalculator extends Resource


## Called when this calculator is set to the [param effect]. A good place
## to call assertions to prevent calculators being applied to effects they may
## not play nicely with. Also called any time a property of [param effect] is modified.
## Only called while in the editor or when the game is running in debug mode.
func _validate_and_assert(effect: AttributeEffect) -> void:
	pass


## Must be overridden to calculate & return the value to be set to an [Attribute]. The below
## attribute values (excluding [param effect_value]) are the current & not final values as
## this method is called during the calculation process of an [Attribute] before values are set
## to the attribute.
## [br][param attr_base_value] represents [method Attribute.get_base_value] at the current point
## in the calculation process. It does NOT represent the final value.
## [br][param attr_current_value] represents [method Attribute.get_current_value] at the current point
## in the calculation process. It does NOT represent the final value.
## [br][member effect_value] is the value derived from the [AttributeEffect].
func _calculate(attr_base_value: float, attr_current_value: float, effect_value: float) -> float:
	assert(false, "_calculate not implemented")
	return 0.0
