extends Node


func _ready() -> void:
	var test: TestNode = TestNode.new()
	add_child(test)
	
