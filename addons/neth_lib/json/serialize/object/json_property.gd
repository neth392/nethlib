## Represents a property within an [Object] that is configured for
## JSON serialization.
class_name JSONProperty extends Resource

enum IfMissing {
	IGNORE,
	WARN,
	ERROR,
}

## The key of the property in the JSON file. Should NOT be changed as it will
## break existing save files. 
@export var json_key: StringName

@export var enabled: bool = true

## What to do if this property is missing from a object during serialization.
@export var if_missing_serialize: IfMissing

## What to do if this property is missing from JSON text during deserialization.
@export var if_missing_deserialize: IfMissing
