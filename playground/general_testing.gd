@tool
extends Node

@export var id: String

func _ready() -> void:
	var packed_array: PackedStringArray = PackedStringArray()
	var array: Array[String] = []
	var dictionary: Dictionary = {}
	for i in 10000:
		packed_array.append(str(i))
		array.append(str(i))
		dictionary[str(i)] = null
	
	var start_time: int = Time.get_ticks_msec()
	for i in 10000:
		dictionary.has(str(i))
	
	var stop_time: int = Time.get_ticks_msec()
	print("Dictionary: " + str(stop_time - start_time)+"ms")
	
	var start_time2: int = Time.get_ticks_msec()
	for i in 10000:
		packed_array.has(str(i))
	
	var stop_time2: int = Time.get_ticks_msec()
	print("PackedStringArray: " + str(stop_time2 - start_time2)+"ms")
	
	var start_time3: int = Time.get_ticks_msec()
	for i in 10000:
		array.has(str(i))
	
	var stop_time3: int = Time.get_ticks_msec()
	print("Array[String]: " + str(stop_time3 - start_time3)+"ms")
