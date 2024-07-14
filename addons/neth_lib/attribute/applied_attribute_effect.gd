class_name AppliedAttributeEffect extends Resource

var effect: AttributeEffect
var stack_count: int
var tick_duration: bool = true
var remaining_duration: float
var _is_active: bool = false

func _init(_effect: AttributeEffect, _stack_count: int = 1) -> void:
	effect = _effect
	stack_count = _stack_count


## Returns true if this [AppliedAttributeEffect] is active, false if not.
func is_active() -> bool:
	return _is_active
