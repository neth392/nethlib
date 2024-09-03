class_name GeneralTesting extends Node

@export var test: Array[int]

func _ready() -> void:
	for prop in get_property_list():
		PROPERTY_HINT_ARRAY_TYPE
		print(prop)
