class_name GeneralTesting extends Node

@onready var test: Variant

func _ready() -> void:
	for property in get_property_list():
		print(property)
