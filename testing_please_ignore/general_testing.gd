class_name GeneralTesting extends Node

@onready var test: Variant

func _ready() -> void:
	var new: JSONSerializationImpl = JSONSerialization.new()
	print(new == JSONSerialization)
