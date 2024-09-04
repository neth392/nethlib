## A wrapper of a simple [member id] which represents information specific to
## an object's type. Will only work with an [Object]s direct type, not any parent/ancestor
## or inherited types.
class_name JSONObjectIdentifier extends Resource

## Constructs a new [JSONObjectIdentifier] from the [param object]. First
## checks if there is a script attached, and uses the [method Script.get_global_name]
## if not empty. If that fails, [method Object.get_class] is used if it is not empty.
## And if that fails, an error is thrown via assert(false).
static func from_object(object: Object) -> JSONObjectIdentifier:
	assert(object != null, "object is null")
	var script: Script = object.get_script() as Script
	if script != null && !script.get_global_name().is_empty():
		return from_class_name(script.get_global_name())
	if !object.get_class().is_empty():
		return from_class_name(object.get_class())
	assert(false, "object (%s) does not have a class defined" % object)
	return null


## Constructs a new [JSONObjectIdentifier] from the [param property]. The property
## must be of TYPE_OBJECT or TYPE_ARRAY, and must have a static type defined.
static func from_property(property: Dictionary) -> JSONObjectIdentifier:
	assert(!property.is_empty(), "property is empty")
	assert(property.has("type"), "property dictionary missing \"type\" key for property (%s)" % property)
	assert(property.type == TYPE_OBJECT || property.type == TYPE_ARRAY, 
	"property.type must be TYPE_OBJECT or TYPE_ARRAY to resolve the ID for property (%s)" % property)
	
	if property.type == TYPE_OBJECT:
		assert(!property.class_name.is_empty(), ("property.class_name is empty for property (%s); " + \
		"non-statically typed properties not supported") % property)
		return JSONObjectIdentifier.new(property.class_name)
	else:
		assert(property.hint == PROPERTY_HINT_TYPE_STRING, ("array property (%s) hint is not" + \
		"PROPERTY_HINT_TYPE_STRING, cant resolve the type" % property))
		var _class_name: String = property.hint_string.split(":")[0]
		assert(!_class_name.is_empty(), "array property (%s) hint_string does not contain a type" \
		% property)
		return JSONObjectIdentifier.new(_class_name)


## Constructs a new [JSONObjectIdentifier] from any class name (built in or custom class)
static func from_class_name(_class_name: StringName) -> JSONObjectIdentifier:
	assert(!_class_name.is_empty(), "_class_name is empty")
	return JSONObjectIdentifier.new(_class_name)


static func from_script_path(script_path: String) -> JSONObjectIdentifier:
	assert(!script_path.is_empty(), "script_path is empty")
	# TODO
	return null

## The class which this represents
@export_custom(PROPERTY_HINT_TYPE_STRING, &"Object") var id: StringName


func _init(_id: StringName = &"") -> void:
	id = id


func _to_string() -> String:
	return "JSONObjectIdentifier(id=%s)" % id
