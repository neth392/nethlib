class_name GeneralTesting extends Node

var node_path: NodePath = NodePath(^"SerializeThis/LabelSerializeThis/Label:text")


func _ready() -> void:
	TYPE_OBJECT
	_handle(&"Label")

func _handle(_class: StringName) -> void:
	print(_class)
	for property in ClassDB.class_get_property_list(_class, true):
		print(property)
	var parent: StringName = ClassDB.get_parent_class(_class)
	if !parent.is_empty():
		_handle(parent)
