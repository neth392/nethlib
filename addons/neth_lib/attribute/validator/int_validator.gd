## Validator that ensures an [Attribute]'s base and/or current value is always
## an integer.
class_name IntValidator extends AttributeValueValidator

enum Rounding {
	NORMAL = 0,
	ROUND_UP = 1,
	ROUND_DOWN = 2,
}
