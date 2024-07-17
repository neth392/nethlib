@tool
extends Node

@export var id: String

func _ready() -> void:
	var test: Test2 = Test2.new()

	for method: Dictionary in test.get_script().get_script_method_list():
		print(" ")
		print(method)
		print(" ")
