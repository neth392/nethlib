@tool
class_name NethLibPlugin extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("PlatformManager", "platform/platform_manager.tscn")
	add_autoload_singleton("AudioStreamer", "audio/audio_streamer.tscn")


func _exit_tree():
	remove_autoload_singleton("PlatformManager")
	remove_autoload_singleton("AudioStreamer")


func _get_plugin_name() -> String:
	return "NethLib"
