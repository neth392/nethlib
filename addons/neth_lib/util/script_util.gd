## Utilities for working with [Script]s.
class_name ScriptUtil extends Object


## Returns the number of times the method with the name [param method_name]
## appears in the [param script]'s [method Script.get_script_method_list].
static func get_method_count(script: Script, method_name: String):
	var count: int = 0
	for method: Dictionary in script.get_script_method_list():
		if method.name == method_name:
			count += 1
	return count
