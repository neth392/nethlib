extends Node


func _ready() -> void:
	var array: Array = ["", ""]
	var r: Array = range(array.size() - 1, -1, -1)
	
	print(r)
