## Callback that adds tags to an [Attribute]'s [AttributeContainer] for the
## duration of the effect. Does nothing if the effect is instant.
class_name TagApplierCallback extends AttributeEffectCallback

## The tags to be added for the duration of the [AttributeEffect].
@export var tags: Array[StringName]

@export_group("Debug Errors")

## If true and [function Attribute.get_container] is null, a debug error will be thrown.
@export var error_on_no_container: bool = false

## If true and [AttributeEffectSpec] is instant, a debug error will be thrown.
@export var error_on_instant: bool = false

func _pre_add(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	if error_on_instant:
		assert(!spec.is_instant(), "AttributeEffectSpec is instant")
	var container: AttributeContainer = attribute.get_container()
	if container != null:
		attribute.get_container().add_tags(tags)
	elif error_on_no_container:
		assert(false, "no container for attribute: %s" % attribute)


func _pre_remove(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	if error_on_instant:
		assert(!spec.is_instant(), "AttributeEffectSpec is instant")
	var container: AttributeContainer = attribute.get_container()
	if container != null:
		attribute.get_container().remove_tags(tags)
	elif error_on_no_container:
		assert(false, "no container for attribute: %s" % attribute)


## Called after the [param spec]'s stack count has changed. [param previous_stack_count] was
## the previous count before the change.
func _stack_changed(attribute: Attribute, spec: AttributeEffectSpec, previous_stack_count: int) -> void:
	pass
