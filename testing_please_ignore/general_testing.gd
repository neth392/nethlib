class_name GeneralTesting extends Node

@export var script_to_test: Script

func _ready() -> void:
	var label: Label = Label.new()
	print(label.get_class())
	label.get_script()
	print("NAME: " + GeneralTesting.new().get_class())
