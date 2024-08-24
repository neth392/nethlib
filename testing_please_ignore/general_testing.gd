class_name GeneralTesting extends Node

@export var test_script: GDScript

func _ready() -> void:
	for method: Dictionary in test_script.get_method_list():
		pass
