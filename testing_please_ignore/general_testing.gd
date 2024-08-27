class_name GeneralTesting extends Node

@export var sc: PackedScene

func _ready() -> void:
	var node: Node
	for prop in sc.instantiate().get_property_list():
		print(prop)


func _handle(_class: StringName) -> void:
	get_property_list()
