## Represents a property within an [Object] that is configured for
## JSON serialization.
class_name JSONProperty extends Resource

## How to handle properties missing in objects or serialized objects.
enum IfMissing {
	## Properties missing in an [Object] or serialized version of an [Object] are ignored.
	IGNORE,
	## Properties missing in an [Object] or serialized version of an [Object] trigger
	## console warnings in debug mode only.
	WARN_DEBUG,
	## Properties missing in an [Object] or serialized version of an [Object] trigger
	## errors via assertions in debug mode only.
	ERROR_DEBUG,
}

## The key of the property in the JSON file. Should NOT be changed as it will
## break existing save files. 
@export var json_key: StringName

## The name of the property in the [Object].
@export var name: StringName

## If this property should be serialized or not.
@export var enabled: bool = true

## If false, null values found in serializing and/or deserializing will trigger
## an error in debug mode.
@export var allow_null: bool = true

## What to do if this property is missing from a object during serialization.
@export var if_missing_serialize: IfMissing

## What to do if this property is missing from JSON text during deserialization.
@export var if_missing_deserialize: IfMissing


func _to_string() -> String:
	return "JSONProperty(json_key=%s,name=%s)" % [json_key, name]
