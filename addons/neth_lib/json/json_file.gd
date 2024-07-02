## Represents a JSON file that can be loaded & saved when needed. [JSONConnector]s
## can be added to be notified of saving/loading.
@tool
class_name JSONFile extends Node

## The absolute path of the file.
@export var absolute_path: String

var _connectors_by_key: Dictionary = {}

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


## Adds the [param json_connector] and wraps it in a [WeakRef] so that
## if the [JSONConnector] node is queue_free'd then it will no longer be active.
func add_connector(json_connector: JSONConnector) -> void:
	assert(json_connector != null, "json_connector is null")
	assert(!_connectors_by_key.has(json_connector.key), ("json_connector with key %s " + \
	"already added" % json_connector.key))
	_connectors_by_key[json_connector.key] = json_connector


## TODO determine if it needs to be made async
func load_and_provide() -> Error:
	assert(FileAccess.file_exists(absolute_path), "absolute_path (%s) does not exist")
	var loaded_string: String = FileAccess.get_file_as_string(absolute_path)
	
	if loaded_string.is_empty():
		return FileAccess.get_open_error()
	
	var root_json: Dictionary = JSONSerialization.parse(loaded_string)
	_iterate_connectors(_load_and_provide.bind(root_json))
	
	return OK


## TODO determine if it needs to be made async
func fetch_and_save() -> Error:
	var root_json: Dictionary = {}
	# Iterate connectors to fetch data to be saved
	_iterate_connectors(_fetch_and_save.bind(root_json))
	
	var json_string: String = JSONSerialization.stringify(root_json)
	var file_access: FileAccess = FileAccess.open(absolute_path, FileAccess.WRITE)
	var open_error: Error = FileAccess.get_open_error()
	if open_error != OK:
		return open_error
	file_access.store_string(json_string)
	var error: Error = file_access.get_error()
	file_access.close()
	return error


func _load_and_provide(connector: JSONConnector, root_json: Dictionary) -> void:
	var value: Variant = root_json.get(connector.key)
	connector.provided.emit(value)


func _fetch_and_save(connector: JSONConnector, root_json: Dictionary) -> void:
	var json_fetcher: JSONFetcher = JSONFetcher.new()
	connector.fetched.emit(json_fetcher)
	root_json[connector.key] = json_fetcher.value


func _iterate_connectors(connector_consumer: Callable) -> void:
	for key: String in _connectors_by_key.keys():
		var ref: WeakRef = _connectors_by_key.get(key) as WeakRef
		var json_connector: JSONConnector = ref.get_ref() as JSONConnector
		if json_connector != null:
			connector_consumer.call(json_connector)
		else:
			_connectors_by_key.erase(key)
