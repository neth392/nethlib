## Condition that is met if an [Attribute]'s [AttributeContainer] has
## all (or none) of the [member tags].
class_name ContainerTagCondition extends AttributeEffectCondition

## How this condition is determined.
enum Mode {
	## Condition is met if the [AttributeContainer] of the [Attribute] has
	## ALL of the [member tags].
	HAS_TAG,
	## Condition is met if the [AttributeContainer] of the [Attribute] does NOT have
	## ANY of the [member tags].
	DOESNT_HAVE_TAG,
}

## Which groups should be checked.
@export var tags: Array[StringName]

## The mode of this condition, see [enum AttributeEffecctTagCondition.Mode].
@export var mode: Mode


func _meets_condition(attribute: Attribute, spec: AttributeEffectSpec) -> bool:
	assert(attribute != null, "attribute is null")
	var container: AttributeContainer = attribute.get_container()
	assert(container != null, "AttributeContainer is null for attribute (%s)" % attribute)
	match mode:
		Mode.HAS_TAG:
			for tag: StringName in tags:
				if !container.has_tag(tag):
					return false
		Mode.DOESNT_HAVE_TAG:
			for tag: StringName in tags:
				if container.has_tag(tag):
					return false
	return true
