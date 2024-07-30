extends Node


func _ready() -> void:
	var array: Array[int] = []
	for i in 100000:
		array.append(i)
		
	ExecutionTimeTest.start()
	for i in array:
		i + 2
	ExecutionTimeTest.print_time_taken("in array")
	
	var range: Array[int] = []
	range.assign(range(array.size()))
	ExecutionTimeTest.start()
	var val: float = 0.0
	for i in range:
		array[i] + 2
	ExecutionTimeTest.print_time_taken("in range")
