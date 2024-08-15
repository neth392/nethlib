## Autoloaded node that manages [Platform]s.
@tool
extends Node

@export var _platforms: Array[Platform] = []

var _active_platform_ids: PackedStringArray = PackedStringArray()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	for platform: Platform in _platforms:
		assert(platform != null, "_platforms has a null element")
		var detector: PlatformDetector = platform.instantiate_detector()
		assert(detector != null, "detector for %s is null" % platform)
		if !detector._is_active():
			print_debug("Platform (%s) not active." % platform.id)
			continue
		print_debug("Platform active: " + platform.id)
		var handler: PlatformHandler = platform.instantiate_handler()
		assert(handler != null, "handler for %s is null" % platform)
		_active_platform_ids.append(platform.id)
		add_child(handler)


## Returns a new [PackedStringArray] containing the [member Platform.id]s of 
## all registered [Platform]s.
func get_platform_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for platform: Platform in _platforms:
		ids.append(platform.id)
	return ids


## Helper function to get all [member Platform.id]s as a concatenated,
## comma seperated [String]. For example, it could return 
## "steam,otherplatform,another" etc.
func get_concatenated_ids() -> String:
	var id_string: String = ""
	var size: int = _platforms.size()
	for index: int in size:
		id_string += _platforms[index].id
		if index < size - 1:
			id_string += ","
	return id_string


## Returns true if the [Platform] with the [param platform_id] is active,
## false if not.
func is_platform_active(platform_id: String) -> bool:
	return _active_platform_ids.has(platform_id)
