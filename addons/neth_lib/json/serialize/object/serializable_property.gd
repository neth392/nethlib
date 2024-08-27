class_name SerializableProperty extends Resource

## The key of the property in the JSON file.
@export var json_key: StringName



func _set_property(object: Object, value: Variant) -> void:
	# TODO assert overridden
	pass


func _get_property(object: Object) -> Variant:
	# TODO assert overridden
	return null
