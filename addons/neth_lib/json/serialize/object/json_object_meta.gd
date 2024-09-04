## Utility class for managing [JSONObjectConfig] within [Object] meta.
class_name JSONObjectMeta extends Object

const KEY: StringName = &"nethlib_json"


static func has_config(object: Object) -> bool:
	assert(object != null, "object is null")
	return object.get_meta(KEY, null) is JSONObjectConfig


static func get_config(object: Object) -> JSONObjectConfig:
	assert(object != null, "object is null")
	return object.get_meta(KEY, null)


static func set_config(object: Object, config: JSONObjectConfig) -> void:
	assert(object != null, "object is null")
	assert(config != null, "config is null")
	object.set_meta(KEY, config)


static func create_config(object: Object) -> JSONObjectConfig:
	assert(object != null, "object is null")
	assert(!has_config(object), "object (%s) already has an JSONObjectConfig" % object)
	var config: JSONObjectConfig = JSONObjectConfig.new()
	set_config(object, config)
	return config


static func clear_config(object: Object) -> void:
	assert(object != null, "object is null")
	object.remove_meta(KEY)
