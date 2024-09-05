## Utility functions to extract the class names out of objects and properties.
class_name JSONClassUtil extends Object

## Resolves the class name from the [param object], or throws an error (only in debug)
## and returns an empty [StringName] if the [param object] does not have a valid class name.
static func from_object(object: Object) -> StringName:
	assert(object != null, "object is null")
	var script: Script = object.get_script() as Script
	if script != null && !script.get_global_name().is_empty():
		return script.get_global_name()
	if !object.get_class().is_empty():
		return object.get_class()
	assert(false, "object (%s) does not have a class defined" % object)
	return &""


### Constructs a new [JSONObjectIdentifier] from the [param property]. The property
### must be of TYPE_OBJECT, and must have a static type defined.
#static func from_property(property: Dictionary) -> StringName:
	#assert(!property.is_empty(), "property is empty")
	#assert(property.has("type"), "property dictionary missing \"type\" key for property (%s)" % property)
	#assert(property.type == TYPE_OBJECT || property.type == TYPE_ARRAY, 
	#"property.type must be TYPE_OBJECT or TYPE_ARRAY to resolve the ID for property (%s)" % property)
	#
	#if property.type == TYPE_OBJECT:
		#assert(!property.class_name.is_empty(), ("property.class_name is empty for property (%s); " + \
		#"non-statically typed properties not supported") % property)
		#return property.class_name
	#else:
		#assert(property.hint == PROPERTY_HINT_TYPE_STRING, ("array property (%s) hint is not" + \
		#"PROPERTY_HINT_TYPE_STRING, cant resolve the type" % property))
		#var _class_name: String = property.hint_string.split(":")[0]
		#assert(!_class_name.is_empty(), "array property (%s) hint_string does not contain a type" \
		#% property)
		#return _class_name
