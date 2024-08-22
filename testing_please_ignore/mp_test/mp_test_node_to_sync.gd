class_name MpTestNodeToSync extends VBoxContainer

@export var test_sync_string: String:
	set(value):
		test_sync_string = value
		if string_label != null:
			string_label.text = value

@export var test_dictionary: Dictionary

@export var test_array: Array[int]

@onready var string_label: Label = $StringLabel

func _ready() -> void:
	string_label.text = test_sync_string

func _to_string() -> String:
	return ObjectUtil.to_string_helper("MpTestNodeToSync", self)

@rpc("any_peer", "call_remote")
func set_test_sync_string(text: String) -> void:
	test_sync_string = text
