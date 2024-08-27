@tool
class_name GetterSetterSerializableProperty extends Resource

@export var setter: StringName
@export var getter: StringName

func _validate_property(property: Dictionary) -> void:
	pass


func _set_property(object: Object, value: Variant) -> void:
	object.call(setter, value)


func _get_property(object: Object) -> Variant:
	return object.call(getter)
