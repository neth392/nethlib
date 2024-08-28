class_name JSONBottomPanel extends Control

@onready var add_button: Button = %AddButton

var _selected_node: Node:
	set(value):
		_selected_node = value
		_update()


func _ready() -> void:
	push_warning("READY")
	EditorInterface.get_selection().selection_changed.connect(_on_editor_selection_changed)


func _update() -> void:
	pass


func _on_editor_selection_changed() -> void:
	var selected: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	if selected.size() != 1:
		push_warning("HIDE")
		hide()
	else:
		push_warning("SHOW")
		show()
