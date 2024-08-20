extends Node


func _ready() -> void:
	var empty_array: Array[String] = []
	var times: int = 1_000_000
	
	ExecutionTimeTest.start()
	for i in times:
		if empty_array.is_empty():
			continue
		for x: String in empty_array:
			print(x)
	ExecutionTimeTest.print_time_taken("is_empty")
	
	
	ExecutionTimeTest.start()
	for i in times:
		for x: String in empty_array:
			print(x)
	ExecutionTimeTest.print_time_taken("iterate")
