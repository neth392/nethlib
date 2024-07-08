## Utilities that deal with audio busses of the [AudioServer].
@tool
extends Node

var _bus_names: PackedStringArray = PackedStringArray()

func _ready() -> void:
	update_bus_layout()
	AudioServer.bus_layout_changed.connect(_on_bus_layout_changed)
	AudioServer.bus_renamed.connect(_on_bus_renamed)


func get_bus_names() -> PackedStringArray:
	return _bus_names.duplicate()


func update_bus_layout() -> void:
	_bus_names.clear()
	for index: int in AudioServer.bus_count:
		var bus_name: String = AudioServer.get_bus_name(index)
		if !_bus_names.has(bus_name):
			_bus_names.append(bus_name)


func _on_bus_layout_changed() -> void:
	update_bus_layout()


func _on_bus_renamed(bus_index: int, old_name: StringName, new_name: StringName) -> void:
	var old_index: int = _bus_names.find(old_name)
	if old_index > -1:
		_bus_names.remove_at(old_index)
	if !_bus_names.has(new_name):
		_bus_names.append(new_name)
