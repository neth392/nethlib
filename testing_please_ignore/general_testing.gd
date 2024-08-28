class_name GeneralTesting extends Node

@export var sc: PackedScene

func _ready() -> void:
	
	var plane: Plane = Plane(Vector3(1, 2, 3), 4)
	plane.x = 5
	print(plane.normal)
	
	var path: NodePath = NodePath("SerializeThis/Label")
	print("BEFORE: " + str(path))
	var serialized: String = JSONSerialization.stringify(path)
	print("SERIALIZED: " + serialized)
	var deserialized: NodePath = JSONSerialization.parse(serialized) as NodePath
	print("AFTER: " + str(deserialized))
	print("EQUALS: " + str(path == deserialized))


func _handle(_class: StringName) -> void:
	get_property_list()
