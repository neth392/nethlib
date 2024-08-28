class_name StaticSerializableProperty extends SerializableProperty

@export var property_name: String


func _set_property_value(object: Object, value: Variant) -> void:
	object.set(property_name, value)


func _get_property_value(object: Object) -> Variant:
	return object.get(property_name)
