class_name GeneralTesting extends Node


func _ready() -> void:
	var range: Array = range(1000000)
	var dictionary: Dictionary = {
		"a": 1,
		"b": 2,
		"c": 3,
	}
	
	ExecutionTimeTest.start()
	for i: int in range:
		dictionary.a
	ExecutionTimeTest.print_time_taken("direct lookup")
	ExecutionTimeTest.start()
	for i: int in range:
		dictionary["a"]
	ExecutionTimeTest.print_time_taken("quote lookup")
