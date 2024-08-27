## Represents an object that can be serialized, either scripted or built in (native).
class_name SerializableObject extends Resource

var id: StringName:
	get():
		return _get_id()
	set(value):
		assert(false, "id can not be set, instead override _get_id()")

func _get_id() -> String:
	assert(false, "_get_id() not overridden")
	return ""


func _instantiate(parameters: Array) -> Object:
	assert(false, "_instantiate() not overridden")
	return null


## Returns the same as [method Object._get_property_list] but for
## the object this [SerializableObject] represents.
func _get_serializable_property_list() -> Array[Dictionary]:
	return []
