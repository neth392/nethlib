@tool
class_name JSONDirectory extends Node

@export var path: String

## Whether or not this [JSONDirectory] has had [method scan_files] called
## & has not been [method clear]'d.
var _scanned: bool = false
var _files_by_name: Dictionary


func _ready() -> void:
	assert(!path.is_empty(), "path not set")
	assert(path.get_file().is_empty(), "path set to a directory")
	assert(path.is_absolute_path(), "path not absolute")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if path.is_empty():
		warnings.append("path not set")
	else:
		if !path.get_file().is_empty():
			warnings.append("path not set to a directory")
		if !path.is_absolute_path():
			warnings.append("path not absolute")


## Returns true if this [JSONDirectory] has had [method scan_files] called AND was
## not [method clear]'d, false if othewrise.
func is_scanned() -> bool:
	return _scanned


## Returns true if the directory of [member path] exists in the filesystem, false if not.
func directory_exists() -> bool:
	return FileAccess.file_exists(path)


## Clears this instance, marking it as not scanned (see [method is_scanned]).
func clear() -> void:
	_files_by_name.clear()
	for child: Node in get_children():
		child.queue_free()
	_scanned = false


## Scans this directory for all files, then marks it as scanned (see [method is_scanned]).
func scan_files() -> void:
	clear()
	
	FileAccess.
	
	_scanned = true


## Returns true if there is a [JSONFile] with [member JSONFile.file_name]
func has_file(file_name: String) -> bool:
	assert(is_valid(), "%s not valid, can't call has_file" % self)
	return _files_by_name.has(file_name)


func get_file(file_name: String) -> JSONFile:
	return _files_by_name.get(file_name)


func _to_string() -> String:
	return "JSONDirectory(%s)" % path
