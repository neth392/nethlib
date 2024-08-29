extends NethlibModule

func _get_name() -> String:
	return "audio_streamer"


func _enabled(plugin: NethLibPlugin) -> void:
	plugin.add_autoload_singleton("AudioStreamer", "audio/audio_streamer.tscn")


func _disabled(plugin: NethLibPlugin) -> void:
	plugin.remove_autoload_singleton("AudioStreamer")
