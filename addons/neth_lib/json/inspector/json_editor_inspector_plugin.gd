@tool
class_name JSONEditorInspectorPlugin extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is Node || (object is Resource && object is not Script)


func _parse_end(object: Object) -> void:
	add_property_editor(JSONEditorProperty.META_KEY, JSONEditorProperty.new())
