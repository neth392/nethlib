extends NethlibModule

var bottom_panel_scene: PackedScene = preload("./ui/json_bottom_panel.tscn") as PackedScene
var bottom_panel: Control

func _get_name() -> String:
	return "JSON"


func _enabled(plugin: NethLibPlugin) -> void:
	plugin.add_autoload_singleton("JSONSerialization", "json/serialize/json_serialization.tscn")
	bottom_panel = bottom_panel_scene.instantiate() as Control
	plugin.add_control_to_bottom_panel(bottom_panel, "JSON")


func _disabled(plugin: NethLibPlugin) -> void:
	plugin.remove_control_from_bottom_panel(bottom_panel)
	bottom_panel.queue_free()
	bottom_panel = null
	plugin.remove_autoload_singleton("JSONSerialization")
