## Multiplies effect_value * Attribute Value (either base or current), then adds
## it to the other Attribute Value (either base or current) & returns that result.
## [br]One example use case is to give the current value a % boost of the current
## base value for a TEMPORARY effect. In that case, the effect value could be .10 (10%), then
## [member multiply_effect_value_by] set to [enum Attribute.Value.BASE_VALUE],
## and [member add_to] set to [enum Attribute.Value.CURRENT_VALUE].
class_name MultiplyThenAddCalculator  extends AttributeEffectCalculator

## Takes the percentage of this value to be added to [member add_to].
@export var multiply_effect_value_by: Attribute.Value

## Adds the percentage of [member multiply_effect_value_by] to this value, resulting
## in the final calculated value.
@export var add_to: Attribute.Value

func _calculate(attr_base_value: float, attr_current_value: float, effect_value: float) -> float:
	var product: float
	
	match multiply_effect_value_by:
		Attribute.Value.BASE_VALUE:
			product = attr_base_value * effect_value
		Attribute.Value.CURRENT_VALUE:
			product = attr_current_value * effect_value
		_:
			assert(false, "multiply_effect_value_by (%s) not implemented" % multiply_effect_value_by)
	
	var sum: float
	
	match add_to:
		Attribute.Value.BASE_VALUE:
			sum = attr_base_value + product
		Attribute.Value.CURRENT_VALUE:
			sum = attr_current_value + product
		_:
			assert(false, "multiply_effect_value_by (%s) not implemented" % add_to)
	
	return sum
