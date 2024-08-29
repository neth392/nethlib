@tool
extends NethlibModule

var _bottom_panel_scene: PackedScene = preload("./ui/json_bottom_panel.tscn") as PackedScene
var _bottom_panel: JSONBottomPanel
var _is_bottom_panel_added: bool = false

func _get_name() -> String:
	return "json"


func _enabled(plugin: NethLibPlugin) -> void:
	plugin.add_autoload_singleton("JSONSerialization", "json/serialize/json_serialization.tscn")
	_bottom_panel = _bottom_panel_scene.instantiate() as JSONBottomPanel
	# Call to update if a node is selected at start
	_on_selection_changed(plugin)
	EditorInterface.get_selection().selection_changed.connect(_on_selection_changed.bind(plugin))


func _disabled(plugin: NethLibPlugin) -> void:
	if _is_bottom_panel_added:
		plugin.remove_control_from_bottom_panel(_bottom_panel)
		_is_bottom_panel_added = false
	_bottom_panel.queue_free()
	_bottom_panel = null
	plugin.remove_autoload_singleton("JSONSerialization")


func _on_selection_changed(plugin: NethLibPlugin) -> void:
	var selection: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	if selection.size() != 1:
		plugin.remove_control_from_bottom_panel(_bottom_panel)
		_is_bottom_panel_added = false
		return
	
	_bottom_panel.selected_object = selection[0]
	
	if !_is_bottom_panel_added:
		_is_bottom_panel_added = true
		plugin.add_control_to_bottom_panel(_bottom_panel, "JSON") # TODO keyboard shortcut
