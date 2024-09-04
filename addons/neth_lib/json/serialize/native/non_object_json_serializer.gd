## Abstract [JSONSerializer] implementation that ignores the object_configs
## parameter of the methods. Helps keep the native serializers cleaner
## & easier to manage.
class_name NonObjectJSONSerializer extends JSONSerializer


func _serialize(instance: Variant, impl: JSONSerializationImpl, 
object_configs: Array[JSONObjectConfig]) -> Variant:
	return __serialize(instance, impl)


func _deserialize(serialized: Variant, impl: JSONSerializationImpl, 
object_configs: Array[JSONObjectConfig]) -> Variant:
	return __deserialize(serialized, impl)


func _deserialize_into(serialized: Variant, instance: Variant, impl: JSONSerializationImpl, 
object_configs: Array[JSONObjectConfig]) -> void:
	__deserialize_into(serialized, instance, impl)


func __serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(false, "__serialize not implemented for serializer id (%s)" % id)
	return null


func __deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(false, "__deserialize not implemented for serializer id (%s)" % id)
	return null


func __deserialize_into(serialized: Variant, instance: Variant, impl: JSONSerializationImpl) -> void:
	assert(false, "__deserialize_into not implemented for serializer id (%s)" % id)
