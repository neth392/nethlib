class_name NethlibModule extends Resource


func _get_dependencies() -> PackedStringArray:
	return PackedStringArray()


func _enabled(plugin: NethLibPlugin) -> void:
	pass


func _disabled(plugin: NethLibPlugin) -> void:
	pass
