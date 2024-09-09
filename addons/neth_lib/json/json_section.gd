## A section of a [JSONFile], identified by a key.
class_name JSONSection extends Resource

## The key of this section, used as the key in the JSON data.
@export var section_key: StringName

## The version of this JSON section. Useful for converting old saves.
@export var version: String

## The data within this section.
var _data: Dictionary = {}


## Creates a new [JSONSection] with the [param _section_key] as [member section_key].
func _init(_section_key: StringName = &"") -> void:
	section_key = _section_key


## Clears the stored data in this section.
func clear() -> void:
	_data.clear()


## Returns true if the [param json_key] exists, false if not.
func key_exists(json_key: StringName) -> bool:
	return _data.has(json_key)


## Returns the variant stored at the [param json_key], or [param default_value]
## if the key does not exist.
func get_value(json_key: StringName, default_value: Variant = null) -> Variant:
	return _data.get(json_key, default_value)


## Sets the [param value] as the value of [param json_key], overriding any
## existing value.
func set_value(json_key: StringName, value: Variant) -> void:
	_data[json_key] = value


## Erases the [param json_key] and its value from this section, returning
## true if it existed & was erased, false if not.
func erase(json_key: StringName) -> bool:
	return _data.erase(json_key)


## Returns true if the [param json_key] exists and is a [JSONSection], false if not.
func has_section(json_key: StringName) -> bool:
	return _data.get(json_key, null) is JSONSection


## Returns the [JSONSection] at the [param json_key], or null if it does not exist.
## If the [param json_key] exists & is not a [JSONSection], an error will be thrown in debug,
## or null will be returned if in release.
func get_section(json_key: StringName) -> JSONSection:
	var section: JSONSection = _data.get(json_key, null)
	if section == null:
		return null
	assert(section is JSONSection, "value @ json_key (%s) not a JSONSection" % json_key)
	return null


## Creates a new [JSONSection] at the specified key, overriting any value that already
## exists at that [param json_key]. The newly created [JSONSection] is then returned.
func create_section(json_key: StringName) -> JSONSection:
	var section: JSONSection = JSONSection.new(json_key)
	set_value(json_key, section)
	return section
