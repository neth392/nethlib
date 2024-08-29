@tool
class_name JSONBottomPanel extends MarginContainer

const OUTPUT_COLOR_OK = Color.LAWN_GREEN
const OUTPUT_COLOR_WARNING = Color.YELLOW
const OUTPUT_COLOR_ERROR = Color.SALMON

@onready var selector_button: Button = %SelectorButton
@onready var output_label: Label = %OutputLabel
@onready var output_animation_player: AnimationPlayer = $OutputAnimationPlayer
@onready var property_name_line_edit: LineEdit = %PropertyNameLineEdit
@onready var add_from_name_button: Button = %AddFromNameButton
@onready var warning_texture_rect: TextureRect = %WarningTextureRect


var selected_object: Object:
	set(value):
		selected_object = value
		update()


func print_output(text: String, color: Color) -> void:
	output_animation_player.stop()
	output_label.set("theme_override_colors/font_color", color)
	output_label.text = text
	output_animation_player.play(&"output_animation")


func _ready() -> void:
	selector_button.icon = EditorIconUtil.get_editor_icon("Add")
	warning_texture_rect.texture = EditorIconUtil.get_editor_icon("StatusWarning")
	selector_button.pressed.connect(_on_selector_button_pressed)
	add_from_name_button.pressed.connect(_on_add_from_name_pressed)
	property_name_line_edit.text_changed.connect(_on_property_name_line_edit_text_changed)
	property_name_line_edit.text_submitted.connect(_on_property_entered.bind(false))


func update() -> void:
	pass


func _on_selector_button_pressed() -> void:
	EditorInterface.popup_property_selector(selected_object, _on_property_selected)


func _on_property_selected(property_path: NodePath) -> void:
	if property_path.is_empty():
		return
	var property_name: String = property_path.get_concatenated_subnames().split(":")[0]
	_on_property_entered(property_name, false)


func _on_property_name_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		warning_texture_rect.hide()
		add_from_name_button.disabled = true
		add_from_name_button.tooltip_text = "Property name cannot be blank."
		return
	
	# TODO ensure property doesnt already exist in configuration
	
	for property: Dictionary in selected_object.get_property_list():
		if property.name == new_text:
			warning_texture_rect.hide()
			add_from_name_button.tooltip_text = "Click to add property \"%s\"" % new_text
			add_from_name_button.disabled = false
			return
	
	add_from_name_button.tooltip_text = "No property with name \"%s\" found" % new_text
	warning_texture_rect.tooltip_text = "No property with name \"%s\" found" % new_text
	warning_texture_rect.show()
	add_from_name_button.disabled = true


func _on_add_from_name_pressed() -> void:
	_on_property_entered(property_name_line_edit.text, true)


func _on_property_entered(property_name: String, clear_line_edit: bool) -> void:
	# TODO ensure property doesnt already exist in configuration
	
	# Determine if property exists
	var exists: bool = false
	for property: Dictionary in selected_object.get_property_list():
		if property.name == property_name:
			exists = true
			break
	
	# Property doesn't exist
	if !exists:
		print_output("Property \"%s\" not found" % property_name, OUTPUT_COLOR_ERROR)
		return
	
	if clear_line_edit:
		property_name_line_edit.clear()
	
	# TODO add property
	print_output("Property \"%s\" added." % property_name, OUTPUT_COLOR_OK)
