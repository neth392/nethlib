## Represents a property within an [Object] that is configured for
## JSON serialization.
@tool
class_name JSONProperty extends Resource

## How to handle properties missing in objects or serialized objects.
enum IfMissing {
	## Properties misssing from an Object are ignored.
	IGNORE,
	## Properties missing from an Object trigger console warnings in debug mode only.
	WARN_DEBUG,
	## Properties missing from an Object trigger errors via assertions in debug mode only.
	ERROR_DEBUG,
}

## The key of the property in the JSON file. 
## [br]WARNING: Changing this property will break existing data stored in json. 
@export var json_key: StringName

## The name of the property in the [Object].
@export var property_name: String

@export_group("Advanced")

## If this property should be serialized or not.
@export var enabled: bool = true

## If false, null values found in serializing and/or deserializing will trigger
## an error in debug mode. If true, null values are serialized as null with no 
## warning or error.
@export var allow_null: bool = true

## How to handle properties missing from an [Object] when serializing it.
@export var if_missing_in_object_serialize: IfMissing = IfMissing.WARN_DEBUG

## How to handle properties missing from serialized data when deserialzing an Object.
@export var if_missing_in_data: IfMissing

## How to handle properties that exist in serialized data but are missing from
## the [Object] being deserialized.
@export var if_missing_in_object_deserialize: IfMissing = IfMissing.WARN_DEBUG

## For use only in the editor
var _editor_class_name: StringName:
	set(value):
		_editor_class_name = value
		notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if !Engine.is_editor_hint():
		return
	
	# Add all properties in the class as editor suggestions
	if property.name == "property_name":
		property.hint = PROPERTY_HINT_ENUM_SUGGESTION
		
		var hints: PackedStringArray = PackedStringArray()
		var base_type: String = _editor_class_name
		
		# Handle custom class
		if !ClassDB.class_exists(_editor_class_name):
			# Handle custom classes
			for _class: Dictionary in ProjectSettings.get_global_class_list():
				if _class.class != _editor_class_name:
					continue
				if _class.path.get_extension() != "gd":
					continue
				# Try to load the script
				var script: Script = load(_class.path)
				# Script was loaded
				if script != null:
					for script_property: Dictionary in script.get_script_property_list():
						# Ignore TYPE_NIL properties (not real properties) and non-serializable ones
						if script_property.type != TYPE_NIL \
						and JSONSerialization.is_type_serializable(script_property.type):
							hints.append(script_property.name)
					base_type = script.get_instance_base_type()
		
		# Handle native/base class
		if ClassDB.class_exists(base_type):
			# Handle native classes
			for class_property: Dictionary in ClassDB.class_get_property_list(base_type, false):
				# Ignore TYPE_NIL properties (not real properties) and non-serializable ones
				if class_property.type != TYPE_NIL \
				and JSONSerialization.is_type_serializable(class_property.type):
					hints.append(class_property.name)
		
		property.hint_string = ",".join(hints)


func _to_string() -> String:
	return "JSONProperty(json_key=%s,property_name=%s)" % [json_key, property_name]
