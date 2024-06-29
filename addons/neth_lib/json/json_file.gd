@tool
class_name JSONFile extends Node

@export_file("*.json") var path: String
var _providers: Array[WeakRef] = []


func _ready() -> void:
	assert(!path.is_empty(), "path is empty")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if path.is_empty():
		warnings.append("path is empty")
	elif !path.ends_with(".json"):
		warnings.append("path extension not .json")
	
	return warnings


## Returns the file name of this json file, including extension.
func get_file_name() -> String:
	return path.get_file()


func register_provider(json_provider: JSONProvider) -> void:
	if OS.is_debug_build():
		for ref: WeakRef in _providers:
			assert(ref.get_ref() != json_provider, "json_provider %s already registered" \
			% json_provider)
	_providers.append(weakref(json_provider))


func load_and_provide() -> void:
	pass


func fetch_and_save() -> void:
	pass
