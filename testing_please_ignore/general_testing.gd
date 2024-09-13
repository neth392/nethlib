class_name GeneralTesting extends Node

func _ready() -> void:
	var test_parent1: TestParent = TestParent.new()
	var test_parent2: TestParent = TestParent.new()
	
	
	print(hash(test_parent1) == hash(test_parent2))
	
