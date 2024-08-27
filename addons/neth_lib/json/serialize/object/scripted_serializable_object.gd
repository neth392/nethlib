@tool
class_name ScriptedSerializableObject extends SerializableObject

@export var gd_script: GDScript

func _get_id() -> String:
	return gd_script.resource_path


func _instantiate(parameters: Array) -> Object:
	assert(false, "_instantiate() not overridden")
	return gd_script.new(parameters)


func _get_serializable_property_list() -> Array[Dictionary]:
	return []
