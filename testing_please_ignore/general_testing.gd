class_name GeneralTesting extends Node

@onready var test: Node = $TestParent

func _ready() -> void:
	for property in test.get_property_list():
		print(property)
		print(has_flag(property.usage, PROPERTY_USAGE_DEFAULT))
		print(" ")

# Function to check if a specific flag is present in the total value
func has_flag(total_value: int, flag: int) -> bool:
	return (total_value & flag) != 0
