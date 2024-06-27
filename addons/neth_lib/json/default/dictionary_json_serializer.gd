extends JSONSerializer


func _init() -> void:
	super._init(&"Dictionary", DeserializeMode.BOTH)


func _can_serialize(instance) -> bool:
	return instance is Dictionary


func _serialize(instance: Dictionary) -> Dictionary:
	assert(instance != null, "Array (%s) is not explicitly typed, Array's must " + \
	"be explicitly typed for deserialization purposes" % instance)
		
		
		
		
	return {}


func _deserialize_into(instance, serialized) -> void:
	pass
