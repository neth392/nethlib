class_name ObjectUtil extends Object


static func to_string_helper(_class_name: String, object: Object, 
exclusions: PackedStringArray = PackedStringArray()) -> String:
	var properties: Dictionary = {}
	for property: Dictionary in object.get_property_list():
		if exclusions.has(property.name):
			continue
		var value: Variant = object.get(property.name)
		properties[property.name] = str(value)
	return _class_name + "(" + JSON.stringify(properties) + ")"


## Resolves the class name from the [param object],returns an empty [StringName]
## if the [param object] does not have a valid class name.
static func get_class_name(object: Object) -> StringName:
	assert(object != null, "object is null")
	var script: Script = object.get_script() as Script
	if script != null && !script.get_global_name().is_empty():
		return script.get_global_name()
	if !object.get_class().is_empty():
		return object.get_class()
	return &""
