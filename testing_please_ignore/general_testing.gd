class_name GeneralTesting extends Node


@export var script_to_test: Script


func _ready() -> void:
	var str: String = ""
	var json: JSON = JSON.new()
	json.parse()
