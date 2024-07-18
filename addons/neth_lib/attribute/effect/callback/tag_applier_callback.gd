## Callback that adds tags to an [Attribute]'s [AttributeContainer] when it is added,
## and if configured (and the effect is not instant) removes the tags afterwards.
class_name TagApplierCallback extends AttributeEffectCallback

## The tags to be added for the duration of the [AttributeEffect].
@export var tags: Array[StringName]

## Whether or not the tags should be removed afterwards.
@export var remove_after: bool = true

@export_group("Debug Errors")

## If true and [function Attribute.get_container] is null, a debug error will be thrown.
@export var error_on_no_container: bool = false


func _pre_add(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	var container: AttributeContainer = attribute.get_container()
	if container != null:
		attribute.get_container().add_tags(tags)
	elif error_on_no_container:
		assert(false, "no container for attribute: %s" % attribute)


func _pre_remove(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	if !remove_after:
		return
	var container: AttributeContainer = attribute.get_container()
	if container != null:
		attribute.get_container().remove_tags(tags)
	elif error_on_no_container:
		assert(false, "no container for attribute: %s" % attribute)
