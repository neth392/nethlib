## Callback that adds tags to an [Attribute]'s [AttributeContainer] when it is added,
## and if configured (and the effect is not instant) removes the tags afterwards.
class_name TagApplierCallback extends AttributeEffectCallback

## The tags to be added when the [AttributeEffect] is added.
@export var tags: Array[StringName]

## If true, [member Attribute.tags] are included in the tags applied.
@export var include_effect_tags: bool = false

## Whether or not the tags should be removed afterwards.
@export var remove_after: bool = true

## If true, this callback will cache the tags applied by an [AttributeEffectSpec]
## and use that list when removing tags. Best for cases where [member tags]
## (or [member Attribute.tags] if [member include_effect_tags] is true) are dynamically 
## modified during runtime which could lead to "forgotten" tags on an [AttributeContainer].
## If false, tags are retrieved directly from [member tags] (& possibly [member Attribute.tags]).
@export var cache_tags_to_remove: bool = false:
	set(value):
		cache_tags_to_remove = value
		if !cache_tags_to_remove:
			_cache.clear()

@export_group("Debug Errors")

## If true and [function Attribute.get_container] is null, a debug error will be thrown.
@export var error_on_no_container: bool = false

## Cache for [member cache_tags_to_remove].
var _cache: Dictionary = {}


func _validate_property(property: Dictionary) -> void:
	if property.name == "cache_tags_to_remove":
		if !remove_after:
			property.usage = PROPERTY_USAGE_STORAGE


func _pre_add(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	var container: AttributeContainer = attribute.get_container()
	if container != null:
		var tags_to_apply: Array[StringName] = tags.duplicate()
		
		if include_effect_tags && !spec.get_effect().tags.is_empty():
			tags_to_apply.append_array(spec.get_effect().tags)
		
		if cache_tags_to_remove:
			_cache[spec] = tags_to_apply
		
		attribute.get_container().add_tags(tags_to_apply)
	elif error_on_no_container:
		assert(false, "no container for attribute: %s" % attribute)


func _pre_remove(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	if !remove_after:
		return
	var container: AttributeContainer = attribute.get_container()
	if container != null:
		if cache_tags_to_remove:
			assert(_cache.has(spec), "spec (%s) not in _cache" % [tags])
			attribute.get_container().remove_tags(_cache[spec])
		else:
			attribute.get_container().remove_tags(tags)
			if include_effect_tags && !spec.get_effect().tags.is_empty():
				attribute.get_container().remove_tags(spec.get_effect().tags)
	elif error_on_no_container:
		assert(false, "no container for attribute: %s" % attribute)
