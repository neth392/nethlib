## Utility resource that contains a single property [member platform_id]
## which is exported as a selectable list of the ids of all registered [Platform]s.[br]
@tool
class_name PlatformReference extends Resource

@export var platform_id: String

func _validate_property(property: Dictionary) -> void:
	if property.name == "platform_id":
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = PlatformManager.get_concatenated_ids()


func _to_string() -> String:
	return "PlatformReference(%s)" % platform_id
