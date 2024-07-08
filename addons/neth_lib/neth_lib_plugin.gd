@tool
class_name NethLibPlugin extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("PlatformManager", "platform/platform_manager.tscn")
	add_autoload_singleton("AudioStreamer", "audio/audio_streamer.tscn")
	add_autoload_singleton("AudioBusHelper", "audio/audio_bus_helper.tscn")
	add_autoload_singleton("JSONSerialization", "json/serialize/json_serialization.tscn")


func _exit_tree():
	remove_autoload_singleton("PlatformManager")
	remove_autoload_singleton("AudioStreamer")
	remove_autoload_singleton("AudioBusHelper")
	remove_autoload_singleton("JSONSerialization")


func _get_plugin_name() -> String:
	return "NethLib"
