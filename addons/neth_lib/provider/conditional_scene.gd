@tool
class_name ConditionalScene extends ConditionalReference

@export var scene: PackedScene

func _get_object() -> Object:
	return scene
