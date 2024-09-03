## Utility class for managing [JSONObjectConfiguration] within [Object] meta.
class_name JSONObjectMeta extends Object

const KEY: StringName = &"nethlib_json"


static func has_config(object: Object) -> bool:
	assert(object != null, "object is null")
	return object.get_meta(KEY, null) is JSONObjectConfiguration


static func get_config(object: Object) -> JSONObjectConfiguration:
	assert(object != null, "object is null")
	return object.get_meta(KEY, null)


static func set_config(object: Object, config: JSONObjectConfiguration) -> void:
	assert(object != null, "object is null")
	assert(config != null, "config is null")
	object.set_meta(KEY, config)


static func create_config(object: Object) -> JSONObjectConfiguration:
	assert(object != null, "object is null")
	assert(!has_config(object), "object (%s) already has an JSONObjectConfiguration" % object)
	var config: JSONObjectConfiguration = JSONObjectConfiguration.new()
	set_config(object, config)
	return config


static func clear_config(object: Object) -> void:
	assert(object != null, "object is null")
	object.remove_meta(KEY)
