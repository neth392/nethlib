## Callbacks can be added to an [AttributeEffect] to listen & make changes to
## an [Attribute] or [AttributeEffectSpec] when an [AttributeEffectSpec] is
## added, applied, and removed. For an example use case, see [AttributeEffectTaggerCallback].
@tool
class_name AttributeEffectCallback extends Resource

enum _Function {
	PRE_ADD,
	ADDED,
	PRE_APPLY,
	APPLIED,
	PRE_REMOVE,
	REMOVE
}

static var _functions_by_name: Dictionary = {
	"_pre_add": _Function.PRE_ADD,
	"_added": _Function.ADDED,
	"_pre_apply": _Function.PRE_APPLY,
	"_applied": _Function.APPLIED,
	"_pre_remove": _Function.PRE_REMOVE,
	"_remove": _Function.REMOVE,
}

static var _function_names: Dictionary = {
	_Function.PRE_ADD: "_pre_add",
	_Function.ADDED: "_added",
	_Function.PRE_APPLY: "_pre_apply",
	_Function.APPLIED: "_applied",
	_Function.PRE_REMOVE: "_pre_remove",
	_Function.REMOVE: "_remove",
}

# Used to detect what functions a callback has implemented - trickery here is that
# in the Array Script.get_script_method_list() returns, methods will appear more
# than once if the current or any parent script has overridden them.
static func _set_functions(callback: AttributeEffectCallback):
	if callback._functions_set:
		return
	var script: Script = callback.get_script() as Script
	assert(script != null, "callback.get_script() doesnt return a Script type")
	var possible: Dictionary = {}
	var definite: Dictionary = {}
	
	for method: Dictionary in script.get_script_method_list():
		if _functions_by_name.has(method.name):
			var _function: _Function = _functions_by_name.get(method.name)
			if possible.has(_function):
				definite[_function] = null
			else:
				possible[_function] = null
	
	callback._functions_set = true
	callback._functions.assign(definite.keys())

var _functions_set: bool = false
# Internal cache of what is overridden
var _functions: Array[_Function] = []


func _pre_add(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


func _added(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


func _pre_apply(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


func _applied(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


func _pre_remove(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


func _remove(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass
