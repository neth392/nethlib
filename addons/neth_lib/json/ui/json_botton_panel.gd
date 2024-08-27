class_name JSONBottomPanel extends Control

@onready var add_button: Button = %AddButton


func _ready() -> void:
	EditorInterface.get_selection()
	EditorInterface.get_inspector()
	pass
