## Abstract class for simple built-in implementations of [method AttributeEffectCalculator]
class_name AbstractSimpleCalculator extends AttributeEffectCalculator

## Determines which value of an [Attribute] should be used in the calculation. 
enum AttributeValue {
	## The [member Attribute.base_value] is used in the calculation alongside the provided
	## [AttributeEffect] value.
	BASE_VALUE = 0,
	## The [method Attribute.get_current_value] is used in the calculation alongside the provided
	## [AttributeEffect] value.
	CURRENT_VALUE = 1,
}

## Determines which value of an [Attribute] should be used in the calculation. 
## [br]See [enum AttributeValue]. This is very important and should usually be
## set according to the [enum AttributeEffect.Type] of the effect.
@export var attribute_value_to_use: AttributeValue


func _calculate(attribute_base_value: float, attribute_current_value: float, effect_value: float) -> float:
	match attribute_value_to_use:
		AttributeValue.BASE_VALUE:
			return _simple_calculate(attribute_base_value, effect_value)
		AttributeValue.CURRENT_VALUE:
			return _simple_calculate(attribute_current_value, effect_value)
		_:
			assert(false, "no implementation for attribute_value_to_use (%s)" % attribute_value_to_use)
			return 0.0


## Must be overridden to perform a calculation on [param attribute_value] and [param effect_value].
func _simple_calculate(attribute_value: float, effect_value: float) -> float:
	assert(false, "_simple_calculate not implemented")
	return 0.0
