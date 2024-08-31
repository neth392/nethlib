## Instiator that creates an instance from a [PackedScene]
@tool
class_name SceneJSONObjectInstantiator extends JSONObjectInstantiator

@export var scene: PackedScene:
	set(value):
		if value != null:
			assert(scene.can_instantiate(), "cant instantiate scene %s" % value)
		scene = value


func _instantiate(property: Dictionary, serialized: Dictionary) -> Object:
	assert(scene != null, "scene is null (not set)")
	assert(scene.can_instantiate(), "cant instantiate scene %s" % scene)
	return scene.instantiate()
