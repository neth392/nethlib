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
