class_name ObjectJSONMeta extends Object

const KEY: StringName = &"nethlib_json"

static func get_meta_config(object: Object) -> ObjectJSONConfiguration:
	return object.get_meta(KEY, null)


static func set_meta_config(object: Object, config: ObjectJSONConfiguration) -> void:
	object.set_meta(KEY, config)
