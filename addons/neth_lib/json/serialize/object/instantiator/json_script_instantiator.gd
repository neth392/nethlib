## Instantiator that creates an instance from a [GDScript]
@tool
class_name JSONScriptInstantiator extends JSONInstantiator

## The [GDScript] to be instantiated.
@export var gd_script: GDScript:
	set(value):
		if value != null:
			assert(gd_script.can_instantiate(), "cant instantiate gd_script %s" % value)
		gd_script = value


func _can_instantiate(property: Dictionary, serialized: Dictionary) -> bool:
	return gd_script != null && gd_script.can_instantiate()


func _instantiate(property: Dictionary, serialized: Dictionary) -> Object:
	assert(gd_script != null, "gd_script is null (not set)")
	assert(gd_script.can_instantiate(), "cant instantiate gd_script %s" % gd_script)
	return gd_script.instantiate()
