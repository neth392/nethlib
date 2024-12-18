@tool
extends NethlibModule

func _get_name() -> String:
	return "platform_manager"


func _enabled(plugin: NethLibPlugin) -> void:
	if OS.is_debug_build():
		plugin.add_autoload_singleton("PlatformManager", "platform/platform_manager.tscn")


func _disabled(plugin: NethLibPlugin) -> void:
	if OS.is_debug_build():
		plugin.remove_autoload_singleton("PlatformManager")
