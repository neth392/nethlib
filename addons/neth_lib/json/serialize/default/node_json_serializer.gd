class_name NodeJSONSerializer extends JSONSerializer

var ID: StringName = &"Node"

func _get_id() -> Variant:
	return ID


func _serialize(instance: Variant) -> Variant:
	assert(instance is Node, "instance not of type Node")
	var node: Node = instance as Node
	node.get_path()
	return {
		"name": node.name,
		"path": JSONSerialization.serialize(node.get_path()),
	}



func _deserialize(serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	return null


func _deserialize_into(instance: Variant, serialized: Variant) -> void:
	assert(instance is Node, "instance not of type Node")
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	var node: Node = instance as Node
