extends Node


func _ready() -> void:
	var range: Array = range(1, 100000)
	
	var b: Array = []
	ExecutionTimeTest.start()
	for i: int in range:
		b.append("hi!")
		b.clear()
	ExecutionTimeTest.print_time_taken("global ")
	
	ExecutionTimeTest.start()
	for i: int in range:
		var a: Array = []
		a.append("hi!")
	ExecutionTimeTest.print_time_taken("local ")
