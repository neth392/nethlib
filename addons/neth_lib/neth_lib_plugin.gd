@tool
class_name NethLibPlugin extends EditorPlugin

const SETTING_PREFIX = "nethlib/modules/"

static var _modules: Dictionary = {
	"PlatformManager": {
		"path": "platform/platform_manager.tscn",
		"dependencies": [],
		"enabled": false,
	},
	"AudioStreamer": {
		"path": "audio/audio_streamer.tscn",
		"dependencies": [],
		"enabled": false,
	},
	"AudioBusHelper": {
		"path": "audio/audio_bus_helper.tscn",
		"dependencies": [],
		"enabled": false,
	},
	"JSONSerialization": {
		"path": "json/serialize/json_serialization.tscn",
		"dependencies": [],
		"enabled": false,
	},
	"JSONFileManager": {
		"path": "json/json_file_manager.tscn",
		"dependencies": ["JSONSerialization"],
		"enabled": false,
	},
	"ExecutionTimeTest": {
		"path": "util/execution_time_test.tscn",
		"dependencies": [],
		"enabled": false,
	},
}

var _ignore_project_setting_change: bool = false
var _bottom_panel: Control

func _enter_tree():
	_scan_modules(true)
	var bottom_panel_scene: PackedScene = load("res://addons/neth_lib/json/ui/json_botton_panel.tscn") as PackedScene
	_bottom_panel = bottom_panel_scene.instantiate() as Control
	add_control_to_bottom_panel(_bottom_panel, "JSON")
	SignalUtil.connect_safely(ProjectSettings.settings_changed, _on_project_settings_changed)


func _exit_tree():
	get_editor_interface().get_selection()
	remove_control_from_bottom_panel(_bottom_panel)
	SignalUtil.disconnect_safely(ProjectSettings.settings_changed, _on_project_settings_changed)
	for module_name: String in _modules:
		var module: Dictionary = _modules[module_name]
		if _modules[module_name]["enabled"]:
			remove_autoload_singleton(module_name)
		module.enabled = false


func _get_plugin_name() -> String:
	return "NethLib"


func _on_project_settings_changed() -> void:
	if _ignore_project_setting_change:
		return
	_scan_modules(false)


func _scan_modules(disable_print: bool) -> void:
	for module_name: String in _modules:
		var setting_path: String = _format_module_path(module_name)
		var module: Dictionary = _modules[module_name]
		# Doesn't exist, create the setting
		if !ProjectSettings.has_setting(setting_path):
			_set_setting(setting_path, module)
			if module.enabled:
				_enable_module(module_name, module, false)
			else:
				_disable_module(module_name, module, false)
			continue
		
		var setting_enabled: bool = ProjectSettings.get_setting(setting_path)
		
		# Is enabled but dependencies arent; remove
		if setting_enabled && !_dependencies_enabled(module):
			_set_setting(setting_path, module)
			_disable_module(module_name, module, false)
			push_warning("NethLib: Module %s can't be enabled as it depends on disabled module(s) %s" \
			% [module_name, module.dependencies])
			continue
		
		if setting_enabled != module.enabled:
			if setting_enabled:
				_enable_module(module_name, module, !disable_print && true)
			else:
				_disable_module(module_name, module, !disable_print && true)


func _dependencies_enabled(module: Dictionary) -> bool:
	for dependency: String in module.dependencies:
		if !_modules[dependency].enabled:
			return false
	return true


func _enable_module(module_name: String, module: Dictionary, print_to_console: bool) -> void:
	module.enabled = true
	if !_has_module_singleton(module_name):
		_ignore_project_setting_change = true
		add_autoload_singleton(module_name, module.path)
		_ignore_project_setting_change = false
	if print_to_console:
		push_warning("NethLib: Enabled module %s" % module_name)


func _disable_module(module_name: String, module: Dictionary, print_to_console: bool) -> void:
	module.enabled = false
	if _has_module_singleton(module_name):
		_ignore_project_setting_change = true
		remove_autoload_singleton(module_name)
		_ignore_project_setting_change = false
	if print_to_console:
		push_warning("NethLib: Disabled module %s" % module_name)


func _set_setting(path: String, module: Dictionary) -> void:
	_ignore_project_setting_change = true
	ProjectSettings.set_setting(path, module.enabled)
	ProjectSettings.set_as_basic(path, true)
	ProjectSettings.set_initial_value(path, module.enabled)
	_ignore_project_setting_change = false


func _has_module_singleton(module_name: String) -> bool:
	return ProjectSettings.has_setting("autoload/" + module_name)


func _format_module_path(module_name: String) -> String:
	return SETTING_PREFIX + module_name
