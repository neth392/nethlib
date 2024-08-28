extends NethlibModule


func _get_name() -> String:
	return "AudioBusHelper"


func _enabled(plugin: NethLibPlugin) -> void:
	plugin.add_autoload_singleton("AudioBusHelper", "audio/audio_bus_helper.tscn")


func _disabled(plugin: NethLibPlugin) -> void:
	plugin.remove_autoload_singleton("AudioBusHelper")
