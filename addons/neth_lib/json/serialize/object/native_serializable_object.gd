@tool
class_name NativeSerializableObject extends SerializableObject

@export_custom(PROPERTY_HINT_TYPE_STRING, &"Object") var _class: StringName


func _get_id() -> String:
	assert(false, "_get_id() not overridden")
	return ""
