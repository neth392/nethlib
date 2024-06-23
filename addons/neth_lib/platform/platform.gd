@tool
class_name Platform extends Resource

@export var id: StringName

## The [PlatformHandler] scene
@export var handler_scene: PackedScene


## Instantiates the [member Platform.handler_scene] and returns it as a [PlatformHandler].
func load_handler() -> PlatformHandler:
	assert(handler_scene != null, "handler is null")
	assert(handler_scene.can_instantiate(), "can't instantiate handler_scene %s" \
	% handler_scene.resource_path)
	var handler: PlatformHandler = handler_scene.instantiate() as PlatformHandler
	assert(handler != null," handler (%s) not of type PlatformHandler" % handler_scene.resource_path)
	return handler
