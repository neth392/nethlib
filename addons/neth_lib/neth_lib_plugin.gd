@tool
class_name NethLibPlugin extends EditorPlugin

const SETTING_PREFIX = "nethlib/modules/"

var _modules_scripts: Array[GDScript] = [
	preload("./platform/nethlib_platform_manager_module.gd"),
	preload("./audio/nethlib_audio_streamer_module.gd"),
	preload("./audio/nethlib_audio_bus_helper_module.gd"),
	preload("./util/nethlib_execution_time_test_module.gd"),
]

var _modules: Array[NethlibModule] = []

var _ignore_project_setting_change: bool = false

func _enter_tree():
	for module_script: GDScript in _modules_scripts:
		_modules.append(module_script.new())
	_scan_modules(false)
	SignalUtil.connect_safely(ProjectSettings.settings_changed, _on_project_settings_changed)


func _exit_tree():
	SignalUtil.disconnect_safely(ProjectSettings.settings_changed, _on_project_settings_changed)
	for module: NethlibModule in _modules:
		if module.is_enabled():
			module.disable(self, false)
	_modules.clear()


func _get_plugin_name() -> String:
	return "NethLib"


func _on_project_settings_changed() -> void:
	if _ignore_project_setting_change:
		return
	_scan_modules(true)


func _scan_modules(print_to_console) -> void:
	for module: NethlibModule in _modules:
		# Doesn't exist, create the setting
		if !ProjectSettings.has_setting(module.setting_path):
			_set_setting(module, true)
			module.enable(self, print_to_console)
			continue
		
		var setting_enabled: bool = ProjectSettings.get_setting(module.setting_path)
		
		# Is enabled but dependencies arent; remove
		if setting_enabled && !_dependencies_enabled(module):
			_set_setting(module, false)
			module.disable(self, false)
			push_warning("NethLib: Module %s can't be enabled as it depends on disabled module(s) %s" \
			% [module.name, module.dependencies])
			continue
		
		if setting_enabled != module.is_enabled():
			if setting_enabled:
				module.enable(self, print_to_console)
			else:
				module.disable(self, print_to_console)


func _dependencies_enabled(module: NethlibModule) -> bool:
	for dependency: String in module.dependencies:
		for other_module: NethlibModule in _modules:
			if other_module.name == dependency && !other_module.is_enabled():
				return false
	return true


func _set_setting(module: NethlibModule, enabled: bool) -> void:
	_ignore_project_setting_change = true
	ProjectSettings.set_setting(module.setting_path, enabled)
	ProjectSettings.set_initial_value(module.setting_path, true)
	ProjectSettings.set_as_basic(module.setting_path, true)
	_ignore_project_setting_change = false
