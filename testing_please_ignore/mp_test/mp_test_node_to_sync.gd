class_name MpTestNodeToSync extends VBoxContainer

@export var test_sync_string: String:
	set(value):
		test_sync_string = value
		if string_label != null:
			string_label.text = value
		if multiplayer != null:
			print("test_sync_string set: " + str(multiplayer.multiplayer_peer.get_unique_id()))
	
@export var test_dictionary: Dictionary:
	set(value):
		test_dictionary = value
		if multiplayer != null:
			print("test_dictionary set: " + str(multiplayer.multiplayer_peer.get_unique_id()))

@export var test_array: Array[int]:
	set(value):
		test_array = value
		if multiplayer != null:
			print("test_array set: " + str(multiplayer.multiplayer_peer.get_unique_id()))

@onready var string_label: Label = $StringLabel

func _ready() -> void:
	string_label.text = test_sync_string

func _to_string() -> String:
	return ObjectUtil.to_string_helper("MpTestNodeToSync", self)

@rpc("any_peer", "call_remote")
func set_test_sync_string(text: String) -> void:
	test_sync_string = text
