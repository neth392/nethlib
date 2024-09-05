class_name GeneralTesting extends Node

@export var sss: GDScript

func _ready() -> void:
	print(sss.get_instance_base_type())
