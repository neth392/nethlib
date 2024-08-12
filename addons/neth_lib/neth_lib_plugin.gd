@tool
class_name NethLibPlugin extends EditorPlugin

const SETTING_PREFIX = "nethlib/autoloads/"

static var _autoloads: Dictionary = {
	"PlatformManager": {
		"path": "platform/platform_manager.tscn",
		"dependencies": [""],
	},
	"AudioStreamer": {
		"path": "audio/audio_streamer.tscn",
		"dependencies": [""],
	},
	"AudioBusHelper": {
		"path": "audio/audio_bus_helper.tscn",
		"dependencies": [""],
	},
	"JSONSerialization": {
		"path": "json/serialize/json_serialization.tscn",
		"dependencies": [""],
	},
	"JSONFileManager": {
		"path": "json/json_file_manager.tscn",
		"dependencies": ["JSONSerialization"],
	},
	"ExecutionTimeTest": {
		"path": "util/execution_time_test.tscn",
		"dependencies": [""],
	},
}

var _ignore_project_setting_change: bool = false

func _enter_tree():
	SignalUtil.connect_safely(ProjectSettings.settings_changed, _on_project_settings_changed)
	add_autoload_singleton("PlatformManager", "platform/platform_manager.tscn")
	add_autoload_singleton("AudioStreamer", "audio/audio_streamer.tscn")
	add_autoload_singleton("AudioBusHelper", "audio/audio_bus_helper.tscn")
	add_autoload_singleton("JSONSerialization", "json/serialize/json_serialization.tscn")
	add_autoload_singleton("JSONFileManager", "json/json_file_manager.tscn")
	add_autoload_singleton("ExecutionTimeTest", "util/execution_time_test.tscn")


func _exit_tree():
	SignalUtil.disconnect_safely(ProjectSettings.settings_changed, _on_project_settings_changed)
	remove_autoload_singleton("PlatformManager")
	remove_autoload_singleton("AudioStreamer")
	remove_autoload_singleton("AudioBusHelper")
	remove_autoload_singleton("JSONSerialization")
	remove_autoload_singleton("JSONFileManager")
	remove_autoload_singleton("ExecutionTimeTest")


func _get_plugin_name() -> String:
	return "NethLib"


func _on_project_settings_changed() -> void:
	if _ignore_project_setting_change:
		return
	_scan_autoloads()


func _scan_autoloads() -> void:
	var disabled: PackedStringArray = PackedStringArray()
	for autoload_name: String in _autoloads:
		if disabled.has(autoload_name):
			continue
		var setting_path: String = _format_autoload_path(autoload_name)
		
		if !ProjectSettings.has_setting(setting_path):
			_set_setting(setting_path, false)
			_disable_autoload(autoload_name, disabled)
			continue
		
		var enabled: bool = ProjectSettings.get_setting(setting_path) as bool
		if enabled:
			pass
		else:
			_disable_autoload(autoload_name)


func _disable_autoload(autoload_name: String, already_disabled: PackedStringArray) -> void:
	already_disabled.append(autoload_name)
	
	# Find other autoloads dependent on this one and disable them
	for other_autoload_name: String in _autoloads:
		var other_autoload: Dictionary = _autoloads[other_autoload_name]
		
		if !already_disabled.has(other_autoload_name) \
		and other_autoload["dependencies"].has(other_autoload_name):
			_disable_autoload(other_autoload_name, already_disabled)
	
	if ProjectSettings.has_setting("autoload/" + autoload_name):
		remove_autoload_singleton(autoload_name)


func _set_setting(path: String, value: Variant) -> void:
	_ignore_project_setting_change = true
	ProjectSettings.set_setting(path, value)
	_ignore_project_setting_change = false


func _is_module_enabled() -> void:
	pass


func _format_autoload_path(autoload_name: String) -> String:
	return SETTING_PREFIX + autoload_name
