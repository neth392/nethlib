class_name JSONEditorProperty extends EditorProperty

const META_KEY: StringName = &"nethlib_json"

# An internal value of the property.
var current_value: bool = false:
	set(value):
		if get_edited_object() == null:
			return
		if !value:
			get_edited_object().remove_meta(META_KEY)
		else:
			get_edited_object().set_meta(META_KEY, true)
	get():
		if get_edited_object() == null:
			return false
		return get_edited_object().get_meta(META_KEY, false)


func _init():
	label = "JSON"
	checkable = true
	tooltip_text = "Test Tooltip"
	checked = current_value
	property_checked.connect(_on_property_checked)


func _update_property() -> void:
	checked = current_value


func _on_property_checked(property: StringName, checked: bool) -> void:
	if property == META_KEY:
		current_value = checked
