@tool
class_name ButtonAudioPlayer extends Node

@export var audio_stream: AudioStream
@export var audio_bus: AudioBusSelector = AudioBusSelector.new()
@export var from_position: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	assert(get_parent() is Button, "parent not of type Button")
	(get_parent() as Button).pressed.connect(_on_parent_pressed)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if !(get_parent() is Button): 
		warnings.append("Must be a child of a Button Node")
	if audio_stream == null:
		warnings.append("no audio_stream set")
	if !audio_bus.exists():
		warnings.append("audio_bus %s does not exist" % audio_bus)
	return warnings


func _on_parent_pressed() -> void:
	if audio_stream != null && audio_bus.exists():
		AudioStreamer.play(audio_stream, audio_bus.index, from_position)
