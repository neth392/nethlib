class_name JSONFile extends JSONSection

## The path to the JSON file.
@export var path: String

var _loaded: bool = false

## Clears the stored data, and sets the file's loaded state to false. Usually
## called after data is loaded & stored in the necessary objects.
func clear() -> void:
	super.clear()
	_loaded = false


## Returns true if this file is loaded, false if not.
func is_loaded() -> bool:
	return _loaded


## Loads the JSON from the file.
func load_from_file() -> void:
	_loaded = true
	## TODO


## Saves the data set by [method set_data] to the file path, overriting the existing
## file if one exists, or creating a new file if it does not exist.
func save_to_file() -> void:
	## TODO
	pass