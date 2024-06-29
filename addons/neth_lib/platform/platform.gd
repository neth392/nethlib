## The 
@tool
class_name Platform extends Resource

## The ID of this platform.
@export var id: String

## The [PlatformDetector] script
@export var detector_script: Script

## The [PlatformHandler] scene
@export var handler_scene: PackedScene


## Instantiates the [member detector_script] and returns it as a [PlatformDetector].
func instantiate_detector() -> PlatformDetector:
	assert(detector_script != null, "detector_script is null")
	var detector: PlatformDetector = detector_script.new() as PlatformDetector
	assert(detector != null, "detector_script not of type PlatformDetector")
	return detector


## Instantiates the [member handler_scene] and returns it as a [PlatformHandler].
func instantiate_handler() -> PlatformHandler:
	assert(handler_scene != null, "handler is null")
	assert(handler_scene.can_instantiate(), "can't instantiate handler_scene %s" \
	% handler_scene.resource_path)
	var handler: PlatformHandler = handler_scene.instantiate() as PlatformHandler
	assert(handler != null," handler (%s) not of type PlatformHandler" % handler_scene.resource_path)
	return handler


func _to_string() -> String:
	return "Platform(%s)" % id