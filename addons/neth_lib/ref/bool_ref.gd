## Data object that holds a reference to a bool.
class_name BoolRef extends RefCounted

## The referenced bool.
var value: bool

func _init(_value: bool) -> void:
	value = _value
