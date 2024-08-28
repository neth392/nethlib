class_name SerializableProperty extends Resource

## The key of the property in the JSON file. Should NOT be changed as it will
## break existing save files. 
@export var json_key: StringName


func _set_property(object: Object, value: Variant) -> void:
	assert(false, "_set_property not implemented")
	pass


func _get_property(object: Object) -> Variant:
	# TODO assert overridden
	return null
