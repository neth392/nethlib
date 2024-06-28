class_name JSONFile extends Resource

var path: String

func _init(_path: String) -> void:
	assert(_path.get_extension() == "json", "_path (%s) extension is not .json" % _path)
	path = path


func save() -> void:
	pass
