## Wrapper of an [Array] of [AttributeEffectModifier]s that ensures they are always
## properly sorted by [member AttributeEffectModifier.priority]. It is cumbersome
## in the inspector, but worth it for the less complex code.
class_name AttributeEffectModifierArray extends Resource

## For use in [method Array.sort_custom], returns a bool so that the modifier with
## the greater priority is in front of the other in the array (descending order)
static func _sort_a_before_b(a: AttributeEffectModifier, b: AttributeEffectModifier) -> bool:
	return a.priority > b.priority


## The [AttributeEffectModifier]s of this instance.
@export var _modifiers: Array[AttributeEffectModifier]:
	set(value):
		if !Engine.is_editor_hint():
			assert(!_modifiers.has(null), "_modifiers has null element")
			value.sort_custom(_sort_a_before_b)
		_modifiers = value


## Returns true if the [param modifier] exists, false if not.
func has(modifier: AttributeEffectModifier) -> bool:
	return _modifiers.has(modifier)


## Adds the [param modifier], returning true if added, false if 
## [member AttributeEffectModifier.duplicate_instances] is true & another instance
## existed already.
func add(modifier: AttributeEffectModifier) -> bool:
	assert(modifier != null, "modifier is null")
	if !modifier.duplicate_instances && _modifiers.has(modifier):
		return false
	
	var index: int = 0
	for other_modifier: AttributeEffectModifier in _modifiers:
		if _sort_a_before_b(modifier, other_modifier):
			_modifiers.insert(index, modifier)
			break
		index += 1
	if index == _modifiers.size(): # Wasn't added in loop, append it to back
		_modifiers.append(modifier)
	
	return true


## Removes the [param modifier]. If [param remove_all_instances] is true, all instances
## of it are removed. If false, only the first instance is removed.
func remove(modifier: AttributeEffectModifier, remove_all_instances: bool) -> void:
	_modifiers.erase(modifier)
	if remove_all_instances:
		while _modifiers.has(modifier):
			_modifiers.erase(modifier)


## Modifies the [param value] by applying the [member _modifiers] to it. [param attribute]
## and [param spec] are the context.
func modify_value(value: float, attribute: Attribute, spec: AttributeEffectSpec) -> float:
	var modified_value: float = value
	for modifier: AttributeEffectModifier in _modifiers:
		if !modifier.should_modify(attribute, spec):
			continue
		modified_value = modifier._modify(modified_value, attribute, spec)
		if modifier.stop_processing_modifiers:
			return modified_value
	return modified_value
