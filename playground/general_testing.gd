extends Node


func _ready() -> void:
	var array: Array[int] = []
	for i in 10000:
		array.append(i)

	ExecutionTimeTest.start()
	for i in array:
		i + 2
	ExecutionTimeTest.print_time_taken("in array")
	
	ExecutionTimeTest.start()
	for i in array.size():
		array[i] + 2
	ExecutionTimeTest.print_time_taken("in range")
