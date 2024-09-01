## A wrapper of a simple [member id] which represents information specific to
## an object's type.
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


## Constructs a new [JSONObjectIdentifier] from the [param property]. 
static func from_property(property: Dictionary) -> JSONObjectIdentifier:
	assert(!property.is_empty(), "property is empty")
	assert(property.has("type"), "property dictionary missing \"type\" key")
	assert(property.type == TYPE_OBJECT, "property.type must be TYPE_OBJECT to resolve the ID")
	assert(!property.class_name.is_empty(), "property.class_name is empty; non-statically typed properties not supported")
	
	# TODO
	
	return JSONObjectIdentifier.new(property.class_name)


## Constructs a new [JSONObjectIdentifier] from any class name (built in or custom class)
static func from_class_name(_class_name: StringName) -> JSONObjectIdentifier:
	assert(!_class_name.is_empty(), "_class_name is empty")
	return JSONObjectIdentifier.new(_class_name)


static func from_script(script: Script) -> JSONObjectIdentifier:
	assert(script != null, "script is null")
	# TODO
	return null


static func from_script_path(script_path: String) -> JSONObjectIdentifier:
	assert(!script_path.is_empty(), "script_path is empty")
	# TODO
	return null

var id: StringName

func _init(_id: StringName) -> void:
	id = id
