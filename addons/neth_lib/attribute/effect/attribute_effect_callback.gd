## Callbacks can be added to an [AttributeEffect] to listen & make changes to
## an [Attribute] or [AttributeEffectSpec] when an [AttributeEffectSpec] is
## added, applied, and removed. For an example use case, see [AttributeEffectTaggerCallback].
@tool
class_name AttributeEffectCallback extends Resource

enum _Function {
	PRE_ADD = 0,
	ADDED = 1,
	APPLIED = 2,
	PRE_REMOVE = 3,
	REMOVED = 4,
	STACK_CHANGED = 5,
}

static var _temporary_functions: Array[_Function] = [
		_Function.PRE_ADD,
		_Function.ADDED,
		_Function.PRE_REMOVE,
		_Function.REMOVED,
		_Function.STACK_CHANGED,
	]

static var _functions_by_name: Dictionary = {
	"_pre_add": _Function.PRE_ADD,
	"_added": _Function.ADDED,
	"_applied": _Function.APPLIED,
	"_pre_remove": _Function.PRE_REMOVE,
	"_removed": _Function.REMOVED,
	"_stack_changed": _Function.STACK_CHANGED,
}

static var _function_names: Dictionary = {
	_Function.PRE_ADD: "_pre_add",
	_Function.ADDED: "_added",
	_Function.APPLIED: "_applied",
	_Function.PRE_REMOVE: "_pre_remove",
	_Function.REMOVED: "_removed",
	_Function.STACK_CHANGED: "_stack_changed",
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


static func _can_run(_function: _Function, effect: AttributeEffect) -> bool:
	if effect.type == AttributeEffect.Type.TEMPORARY:
		return _temporary_functions.has(_function)
	return true


var _functions_set: bool = false
# Internal cache of what functions are overridden
var _functions: Array[_Function] = []


## Editor tool function that is called when this callback is added to [param effect].
## Write assertions here so that callbacks aren't added to effects they won't play nicely with.
func _run_assertions(effect: AttributeEffect) -> void:
	pass


## Called when this callback is added to the [param effect].
## [br]NOTE: Called for both PERMANENT and TEMPORARY effects.
func _added_to_effect(effect: AttributeEffect) -> void:
	pass


## Called when this callback is removed from the [param effect].
## [br]NOTE: Called for both PERMANENT and TEMPORARY effects.
func _removed_from_effect(effect: AttributeEffect) -> void:
	pass


## Called before the [param spec] is to be added to the [param attribute].
## [br]NOTE: Called for both PERMANENT and TEMPORARY effects.
func _pre_add(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


## Called after the [param spec] has been added to the [param attribute].
## [br]NOTE: Called for both PERMANENT and TEMPORARY effects.
func _added(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


## Called after the [param spec] has been applied to the [param attribute].
## [br]NOTE: ONLY called for PERMANENT effects.
func _applied(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


## Called before the [param spec] is to be removed from the [param attribute].
## [br]NOTE: Called for both PERMANENT and TEMPORARY effects.
func _pre_remove(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


## Called after the [param spec] has been removed from the [param attribute].
## [br]NOTE: Called for both PERMANENT and TEMPORARY effects.
func _removed(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	pass


## Called after the [param spec]'s stack count has changed. [param previous_stack_count] was
## the previous count before the change.
## [br]NOTE: Called for both PERMANENT and TEMPORARY effects.
func _stack_changed(attribute: Attribute, spec: AttributeEffectSpec, previous_stack_count: int) -> void:
	pass
