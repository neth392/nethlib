## Utility class for managing [ObjectJSONConfiguration] within [Object] meta.
class_name ObjectJSONMeta extends Object

const KEY: StringName = &"nethlib_json"


static func has_config(object: Object) -> bool:
	assert(object != null, "object is null")
	return object.get_meta(KEY, null) is ObjectJSONConfiguration


static func get_config(object: Object) -> ObjectJSONConfiguration:
	assert(object != null, "object is null")
	return object.get_meta(KEY, null)


static func set_config(object: Object, config: ObjectJSONConfiguration) -> void:
	assert(object != null, "object is null")
	assert(config != null, "config is null")
	object.set_meta(KEY, config)


static func create_config(object: Object) -> ObjectJSONConfiguration:
	assert(object != null, "object is null")
	assert(!has_config(object), "object (%s) already has an ObjectJSONConfiguration" % object)
	var config: ObjectJSONConfiguration = ObjectJSONConfiguration.new()
	set_config(object, config)
	return config


static func clear_config(object: Object) -> void:
	assert(object != null, "object is null")
	object.remove_meta(KEY)
