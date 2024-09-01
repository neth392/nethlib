## Autoloaded class (named JSONSerialization) responsible for managing [JSONSerializer]s and providing
## serialization & deserialization. See [JSONSerializationImpl] for more information.
@tool
extends JSONSerializationImpl

## Constructs a new [JSONSerializationImpl] instance with support for reading errors.
func new() -> JSONSerializationImpl:
	var instance: JSONSerializationImpl = JSONSerializationImpl.new()
	instance._serializers = _serializers.duplicate(false)
	instance._default_object_configs = _default_object_configs.duplicate(false)
	instance.indent = indent
	instance.sort_keys = sort_keys
	instance.full_precision = full_precision
	instance.keep_text = keep_text
	return instance
