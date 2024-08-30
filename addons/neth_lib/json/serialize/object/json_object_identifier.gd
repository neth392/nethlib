class_name JSONObjectIdentifier extends Resource

## Results 
static func resolve_for_object(object: Object) -> JSONObjectIdentifier:
	assert(object != null, "object is null")
	return null


static func resolve_for_property(property: Dictionary) -> JSONObjectIdentifier:
	assert(!property.is_empty(), "property is empty")
	assert(property.has("type"), "property dictionary missing \"type\" key")
	assert(property.type == TYPE_OBJECT, "property.type must be TYPE_OBJECT to resolve the ID")
	assert(!property.class_name.is_empty(), "property.class_name is empty; non-statically typed properties not supported")
	return JSONObjectIdentifier.new(property.class_name)


static func from_class_name(_class_name: StringName) -> JSONObjectIdentifier:
	assert(!_class_name.is_empty(), "_class_name is empty")
	
	# TODO
	return null


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
