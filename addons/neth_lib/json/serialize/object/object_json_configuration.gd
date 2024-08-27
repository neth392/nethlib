@tool
class_name ObjectJSONConfiguration extends Node

@export var await_to_serialize_ready: bool = true
@export var path_to_serialize: NodePath

var properties_to_serialize: Dictionary = {
	
}

func _ready() -> void:
	var node: Node = _get_node()

func _get_node() -> Node:
	get_node_and_resource()
	return get_node(path_to_serialize)
