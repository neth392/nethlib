@tool
extends Node

@export var id: String

func _ready() -> void:
	
	var array: Array[int] = []
	for i in 10000:
		array.append(i)
	
	var start_time: int = Time.get_ticks_msec()
	for i in range(-9999, 1):
		array.erase(i * -1)
	var stop_time: int = Time.get_ticks_msec()
	print(".erase " + str(array.size()) + "time:" + str(stop_time - start_time)+"ms")
	array.clear()
	
	for i in 1000:
		array.append(i)
	
	var start_time2: int = Time.get_ticks_msec()
	for i in range(-9999, 1):
		var num: int = array[i]
		array.remove_at(i * -1)
	var stop_time2: int = Time.get_ticks_msec()
	print(".remove_at " + str(array.size()) + " time: " + str(stop_time2 - start_time2)+"ms")
