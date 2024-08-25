class_name GeneralTesting extends Node

@export var test_script: GDScript
@export_custom(PROPERTY_HINT_TYPE_STRING, &"Object") var type: String:
	set(value):
		type = value


func _ready() -> void:
	# NOTE: Notes for me in json serialization
	# To check if it is a Node or Resource:
	# print(test_script.get_instance_base_type())
	
	# To instantiate a random built in class
	# ClassDB.instantiate("Label")
	
	# Perhaps custom annotaions
	for property in ClassDB.class_get_property_list(&"Label"):
		print(property)
