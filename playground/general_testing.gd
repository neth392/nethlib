extends Node


func _ready() -> void:
	var array: Array = [1, 2, 3, 4, 5, 6]
	print(array)
	print(array.slice(3))
	array.resize(3)
	print(array)
	#var range: Array = range(1, 100000)
	#
	#var d: Dictionary = {}
	#ExecutionTimeTest.start()
	#for i: int in range:
		#d["hi!"] = true
		#d.clear()
	#ExecutionTimeTest.print_time_taken("global ")
	#
	#ExecutionTimeTest.start()
	#for i: int in range:
		#var d1: Dictionary = {}
		#d1["hi!"] = true
	#ExecutionTimeTest.print_time_taken("local ")
