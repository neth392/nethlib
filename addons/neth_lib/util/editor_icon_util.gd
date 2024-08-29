## Utilities for dealing with editor icons.
class_name EditorIconUtil extends Object

const _FOLDER_ICON_NAME: String = "Folder"

static var _folder_icon: Texture2D
static var _file_icon: Texture2D
static var _file_icon_names: Dictionary = {
	"tscn": "PackedScene",
	"gd": "GDScript",
}
static var _file_icons: Dictionary = {}

static func _static_init():
	if !Engine.is_editor_hint():
		return
	_folder_icon = get_editor_icon("Folder")
	_file_icon = get_editor_icon("File")
	
	for extension: String in _file_icon_names:
		var icon_name: String = _file_icon_names[extension]
		_file_icons[extension] = get_editor_icon(icon_name)


static func get_folder_icon() -> Texture2D:
	assert(Engine.is_editor_hint(), "EditorIconUtil only accessible in the editor")
	return _folder_icon


static func get_file_icon() -> Texture2D:
	assert(Engine.is_editor_hint(), "EditorIconUtil only accessible in the editor")
	return _file_icon


static func get_icon_from_extension(path: String, fallback_icon: Texture2D = _file_icon) -> Texture2D:
	assert(Engine.is_editor_hint(), "EditorIconUtil only accessible in the editor")
	return _file_icons.get(path.get_extension(), fallback_icon)


static func has_editor_icon(name: String) -> bool:
	assert(Engine.is_editor_hint(), "EditorIconUtil only accessible in the editor")
	return EditorInterface.get_base_control().has_theme_icon(name, "EditorIcons")


static func get_editor_icon(name: String, fallback_icon: Texture2D = null) -> Texture2D:
	assert(Engine.is_editor_hint(), "EditorIconUtil only accessible in the editor")
	var icon: Texture2D = EditorInterface.get_base_control().get_theme_icon(name, "EditorIcons")
	return icon if icon != null else fallback_icon
