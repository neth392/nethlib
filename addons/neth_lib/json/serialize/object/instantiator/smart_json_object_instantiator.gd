## Uses the class name of the [param property] parameter of [method _instantiate]
## to resolve if the object is a scripted object or native. If it is a script,
## it will load the script & create a new instance (constructor must have ZERO params).
## If it is a native object, a new instance is created via [method ClassDB.instantiate].
## [br]NOTE: DOES NOT WORK PROPERLY WITH [PackedScene]s. Use [SceneJSONObjectInstantiator] 
## for that.
## [br]WARNING: If the static type defined is a parent type, this will not work. Use
## a custom [JSONObjectInstantiator] implementation in that case.
class_name SmartJSONObjectInstantiator extends JSONObjectInstantiator


func _instantiate(property: Dictionary, serialized: Dictionary) -> Object:
	assert(property.type == TYPE_OBJECT, "property (%s) not of TYPE_OBJECT" % property)
	assert(!property.class_name.is_empty(), "property (%s) does not have static type defined" % property)
	
	var _class_name: StringName = property.class_name
	
	# Check if class is built in type
	if ClassDB.class_exists(_class_name):
		assert(ClassDB.can_instantiate(_class_name), "Cannot instantiate class (%s)" % _class_name)
		return ClassDB.instantiate(_class_name)
	
	# Check if class is a custom type
	for _class: Dictionary in ProjectSettings.get_global_class_list():
		if _class_name == _class.class:
			var path: String = _class.path
			var loaded: Resource = load(_class.path)
			assert(loaded is GDScript, "class (%s)'s path (%s) not of type GDScript" \
			% [_class_name, _class.path])
			var gd_script: GDScript = loaded as GDScript
			assert(gd_script.can_instantiate(), "class (%s)'s path (%s) can not be instantiated" \
			% [_class_name, _class.path])
			return gd_script.new()
	
	
	assert(false, "class (%s) not found in ClassDB or ProjectSettings.get_global_class_list()" \
	% _class_name)
	return null
