## Abstract class for simple built-in implementations of [method AttributeEffectCalculator].
class_name AbstractSimpleCalculator extends AttributeEffectCalculator

## Determines which value of an [Attribute] should be used in the calculation. 
## [br]This is very important and should usually be set according to the [enum AttributeEffect.Type]
## of the effect, where PERMANENT effects would use [enum Attribute.Value.BASE_VALUE] and
## TEMPORARY effects would use [enum Attribute.Value.CURRENT_VALUE]. However for more complex
## cases it can be configured to your liking.
## [br]NOTE: For PERMANENT effects, [enum Attribute.Value.CURRENT_VALUE] is always the same as 
## BASE_VALUE, as the base value is calculated before temporary effects are applied and 
## thus the current value won't differ at all.
@export var attribute_value_to_use: Attribute.Value

func _calculate(attribute_base_value: float, attribute_current_value: float, effect_value: float) -> float:
	match attribute_value_to_use:
		Attribute.Value.BASE_VALUE:
			return _simple_calculate(attribute_base_value, effect_value)
		Attribute.Value.CURRENT_VALUE:
			return _simple_calculate(attribute_current_value, effect_value)
		_:
			assert(false, "no implementation for attribute_value_to_use (%s)" % attribute_value_to_use)
			return 0.0


## Must be overridden to perform a calculation on [param attribute_value] and [param effect_value].
func _simple_calculate(attribute_value: float, effect_value: float) -> float:
	assert(false, "_simple_calculate not implemented")
	return 0.0
