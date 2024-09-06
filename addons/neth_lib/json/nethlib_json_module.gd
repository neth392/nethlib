@tool
extends NethlibModule

func _get_name() -> String:
	return "json"


func _enabled(plugin: NethLibPlugin) -> void:
	# Add the autoload
	plugin.add_autoload_singleton("JSONSerialization", "json/serialize/json_serialization.tscn")


func _disabled(plugin: NethLibPlugin) -> void:
	# Remove autoload
	plugin.remove_autoload_singleton("JSONSerialization")
