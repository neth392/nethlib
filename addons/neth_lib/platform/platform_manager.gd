@tool
extends Node

@export var _platforms: Array[Platform] = []

var _current_platforms: Array[Platform]
var _platforms_by_id: Dictionary = {}


func _ready():
	for platform: Platform in _platforms:
		_platforms_by_id[platform.id] = platform


## Returns a new [PackedStringArray] containing the [member Platform.id]s of 
## all registered [Platform]s.
func get_platform_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for id: String in _platforms_by_id.keys():
		ids.append(id)
	return ids
