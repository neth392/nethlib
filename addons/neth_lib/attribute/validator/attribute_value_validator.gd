## Validates either the base and/or current value of an [Attribute], conducting
## operations such as clamping or rounding.
class_name AttributeValueValidator extends Resource


## Consumes [param value] and returns the validated value.
func _validate(value: float) -> float:
	return value
