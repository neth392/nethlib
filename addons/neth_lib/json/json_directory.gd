## A [JSONFile] implementation that is set to an absolute directory. In order
## to be loaded from or saved to, [method scan_files] must first be called to
## obtain a list of the files in the directory. Next, the [member current_file_name]
## must be set. Useful when loading a save from a list of files.
@tool
class_name JSONDirectory extends JSONFile

## Emitted when [member current_file_name] is changed.
signal current_file_changed()

## The absolute path of the directory this [JSONDirectory] represents.
@export var absolute_directory_path: String:
	set(value):
		absolute_directory_path = value
		_update_absolute_path()
		update_configuration_warnings()


## The name of the current file, can't be empty for this [JSONFile] to be loaded.
@export var current_file_name: String:
	set(value):
		current_file_name = value
		_update_absolute_path()
		update_configuration_warnings()
		current_file_changed.emit()


## If true, [method scan_files] will be called in this node's [method _ready] function.
@export var auto_scan: bool = false

## Whether or not this [JSONDirectory] has had [method scan_files] called
## & has not been [method clear]'d.
var _scanned: bool = false
var _file_names: PackedStringArray


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	assert(!absolute_directory_path.is_empty(), "absolute_directory_path not set")
	assert(absolute_directory_path.get_file().is_empty(), "absolute_directory_path not " +\
	"set to a directory")
	assert(absolute_directory_path.is_absolute_path(), "absolute_directory_path not absolute")
	
	if auto_scan:
		scan_files()


func _validate_property(property: Dictionary) -> void:
	if property.name == "current_file_name" && directory_exists():
		property.hint = PROPERTY_HINT_ENUM_SUGGESTION
		var files: PackedStringArray = PackedStringArray([""])
		for file: String in DirAccess.get_files_at(absolute_directory_path):
			if file.ends_with(".json"):
				files.append(file)
		property.hint_string = ",".join(files)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if absolute_directory_path.is_empty():
		warnings.append("absolute_directory_path not set")
	else:
		if !absolute_directory_path.get_file().is_empty():
			warnings.append("absolute_directory_path not set to a directory")
		if !absolute_directory_path.is_absolute_path():
			warnings.append("absolute_directory_path not absolute")
	
	return warnings


func get_file_name() -> String:
	return current_file_name


## Returns true if this [JSONDirectory] has had [method scan_files] called AND was
## not [method clear]'d, false if othewrise.
func is_scanned() -> bool:
	return _scanned


## Returns true if the directory of [member absolute_directory_path] is not empty and
## exists in the filesystem, false if not.
func directory_exists() -> bool:
	return !absolute_directory_path.is_empty() && DirAccess.dir_exists_absolute(absolute_directory_path)


## Clears this instance, marking it as not scanned (see [method is_scanned]).
func clear(clear_current_file: bool = false) -> void:
	_file_names.clear()
	_scanned = false
	if clear_current_file:
		current_file_name = ""


## Scans this directory for all files, then marks it as scanned (see [method is_scanned]).
func scan_files() -> void:
	assert(directory_exists(), "absolute_directory_path (%s) does not exist" % absolute_directory_path)
	clear()
	
	var files: PackedStringArray = DirAccess.get_files_at(absolute_directory_path)
	for file: String in files:
		if file.ends_with(".json"):
			_file_names.append(file)
	if !files.has(current_file_name):
		current_file_name = ""
	
	_scanned = true


## Returns true if there is a [JSONFile] with [member JSONFile.file_name]
func has_file(file_name: String) -> bool:
	assert(is_scanned(), "%s not scanned, can't call has_file" % self)
	return _file_names.has(file_name)


func _update_absolute_path() -> void:
	var splitter: String = "" if absolute_directory_path.ends_with("/") else "/"
	absolute_path = absolute_directory_path + splitter + current_file_name


func _to_string() -> String:
	return "JSONDirectory(%s/%s)" % [absolute_directory_path, current_file_name]
