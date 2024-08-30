## Utilities for working with [Script]s.
class_name ScriptUtil extends Object


## Returns the number of times the method with the name [param method_name]
## appears in the [param script]'s [method Script.get_script_method_list]. Useful
## for determining if a method is inherited or not.
static func get_method_count(script: Script, method_name: String):
	var count: int = 0
	for method: Dictionary in script.get_script_method_list():
		if method.name == method_name:
			count += 1
	return count


## Returns the [Script]'s resource_path from the custom class [param _class_name],
## or an empty string if no custom class with [param _class_name] exists.
static func get_script_path_from_class_name(_class_name: StringName) -> String:
	for global_class: Dictionary in ProjectSettings.get_global_class_list():
		if global_class.class == _class_name:
			return global_class.path
	return ""
