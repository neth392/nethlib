## Editor tool used to export a selectable list of the available audio bus names
## derived from the [AudioServer].
@tool
class_name AudioBusSelector extends Resource

## The name of the audio bus to use.
@export var audio_bus_name: String:
	set(value):
		audio_bus_name = value
		index = AudioServer.get_bus_index(audio_bus_name)


## The index of the [member audio_bus_name] in the [AudioServer]. -1 if the
## [member audio_bus_name] does not exist.
var index: int


func _validate_property(property: Dictionary) -> void:
	if property.name == "audio_bus_name":
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ",".join(AudioBusHelper.get_bus_names())


## Returns true if the set audio bus exists, false if not.
func exists() -> bool:
	return index != -1


func _to_string() -> String:
	return "AudioBusSelector(name:%s,index:%s)" % [audio_bus_name, index]
