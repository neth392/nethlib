@tool
class_name ObjectJSONSerializerBuilder extends ObjectJSONSerializer

## The script of the type this deserializer is for.
@export var object_script: GDScript:
	set(value):
		object_script.get_global_name()
		if object_script != value:
			_property_configuration.clear()
		object_script = value
		notify_property_list_changed()

## Remaps, see [method ObjectJSONSerializer._get_deserialization_remaps]
@export var deserialization_remaps: Dictionary:
	set(value):
		# Assert all keys & values are StringNames
		if Engine.is_editor_hint():
			for key: Variant in value:
				assert(key == null || key is StringName, ("deserialization_remaps key (%s) not " + \
				"of type StringName") % key)
				assert(value[key] == null || value[key] is StringName, ("deserialization_remaps key (%s)'s " +
				" value (%s) not of type StringName") % [key, value[key]])
		deserialization_remaps = value

@export_storage var _property_configuration: Dictionary = {}

func _validate_property(property: Dictionary) -> void:
	pass


func _get_property_list() -> Array[Dictionary]:
	pass


## Must be overridden to return a new instance of the object that is used in
## [method _deserialize].
func _create_instance() -> Object:
	return null


## Must be overridden to return an [Dictionary] of [StringName]s keys representing
## the names of properties that are to be serialized & deserialized. Values
## are [enum IfMissing], true if the value is required, false if optional.[br]
## For performance reasons, it is important the [StringName]s are explicitly
## defined as it speeds up the many [method Object.get] calls this serializer uses.
func _get_properties() -> Dictionary:
	return {}


func _get_deserialization_remaps() -> Dictionary:
	return deserialization_remaps


func _get_priority() -> int:
	return priority
