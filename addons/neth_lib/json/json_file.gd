@tool
class_name JSONFile extends Node

## The absolute path of the file.
@export var absolute_path: String

var _connectors: Array[WeakRef] = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	assert(!absolute_path.is_empty(), "absolute_path is empty")
	assert(absolute_path.ends_with(".json"), "absolute_path extension is not .json")
	assert(absolute_path.is_absolute_path(), "absolute_path not absolute")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if absolute_path.is_empty():
		warnings.append("absolute_path is empty")
	elif !absolute_path.ends_with(".json"):
		warnings.append("absolute_path extension is not .json")
	
	return warnings


## Returns the file name of this json file, including extension.
func get_file_name() -> String:
	return absolute_path.get_file()


## Registers the [param json_connector] and wraps it in a [WeakRef] so that
## if the [JSONConnector] node is queue_free'd then it will no longer be active.
func register_connector(json_connector: JSONConnector) -> void:
	assert(json_connector != null, "json_connector is null")
	if OS.is_debug_build():
		for ref: WeakRef in _connectors:
			assert(ref.get_ref() != json_connector, "json_connector %s already registered" \
			% json_connector)
	_connectors.append(weakref(json_connector))


func load_and_provide() -> void:
	pass


func fetch_and_save() -> void:
	pass
