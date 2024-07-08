@tool
extends Node

var _busses_by_name: Dictionary = {}


func _ready() -> void:
	update_bus_layout()
	AudioServer.bus_layout_changed.connect(_on_bus_layout_changed)


func get_bus_names() -> PackedStringArray:
	return PackedStringArray(_busses_by_name.keys())


func update_bus_layout() -> void:
	_busses_by_name.clear()
	for index: int in AudioServer.bus_count:
		var bus_name: String = AudioServer.get_bus_name(index)
		_busses_by_name[bus_name] = index


func _on_bus_layout_changed() -> void:
	update_bus_layout()
