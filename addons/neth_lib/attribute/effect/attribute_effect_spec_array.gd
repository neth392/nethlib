## Wrapper of an [Array] of [AttributeEffectSpec]s for safety in use with an [Attribute].
## [br]NOTE: This class was designed so that iterating specs based on their features is
## quicker than adding & removing. It is a tradeoff subject to change, but more than
## likely arrays will be iterated constantly while added to / removed from less so.
class_name AttributeEffectSpecArray extends Resource

var _same_priority_sorting_method: Attribute.SamePrioritySortingMethod
var _array: Array[AttributeEffectSpec] = []

# Feature specific arrays
var _only_temps: Array[AttributeEffectSpec] = []
var _only_blockers: Array[AttributeEffectSpec] = []
var _only_modifiers: Array[AttributeEffectSpec] = []

func _init(same_priority_sorting_method: Attribute.SamePrioritySortingMethod) -> void:
	_same_priority_sorting_method = same_priority_sorting_method


## Returns the underlying array for iteration purposes ONLY.
func iterate() -> Array[AttributeEffectSpec]:
	return _array


## Returns an underlying array of only TEMPORARY [AttributeEffectSpec]s, for
## iteration purposes ONLY.
func iterate_temp() -> Array[AttributeEffectSpec]:
	return _only_temps


## Returns an underlying array of only blocker [AttributeEffectSpec]s, for
## iteration purposes ONLY.
func iterate_blockers() -> Array[AttributeEffectSpec]:
	return _only_blockers


## Returns an underlying array of only modifier [AttributeEffectSpec]s, for
## iteration purposes ONLY.
func iterate_modifiers() -> Array[AttributeEffectSpec]:
	return _only_modifiers


## Returns the range to iterate the undelrying array in reverse.
func iterate_reverse() -> Array:
	return range(_array.size() -1, -1, -1)


func add(spec_to_add: AttributeEffectSpec) -> int:
	assert(!_array.has(spec_to_add), "spec_to_add (%s) already present" % spec_to_add)
	var index: int = _add_to_sorted_array(_array, spec_to_add)
	
	if spec_to_add.get_effect().is_temporary():
		_add_to_sorted_array(_only_temps, spec_to_add)
	
	if spec_to_add.get_effect().is_blocker():
		_add_to_sorted_array(_only_blockers, spec_to_add)
	
	if spec_to_add.get_effect().is_modifier():
		_add_to_sorted_array(_only_modifiers, spec_to_add)
	
	return index


func _add_to_sorted_array(add_to: Array[AttributeEffectSpec], spec_to_add: AttributeEffectSpec) -> int:
	var index: int = 0
	for spec: AttributeEffectSpec in add_to:
		if _sort_new_before_other(spec_to_add, spec):
			add_to.insert(index, spec_to_add)
			break
		index += 1
	
	# Append if not added during loop
	if index == add_to.size():
		add_to.append(spec_to_add)
	
	return index


func _sort_new_before_other(new: AttributeEffectSpec, other: AttributeEffectSpec) -> bool:
	if new.get_effect().type != other.get_effect().type:
		return new.get_effect().type < other.get_effect().type
	if new.get_effect().priroity == other.get_effect().priority:
		match _same_priority_sorting_method:
			Attribute.SamePrioritySortingMethod.OLDER_FIRST:
				return false
			Attribute.SamePrioritySortingMethod.NEWER_FIRST:
				return true
			_:
				assert(false, "no implementation for _same_priority_sorting_method (%s)" \
				% _same_priority_sorting_method)
	return new.get_effect().priority > other.get_effect().priority


func erase(spec: AttributeEffectSpec) -> void:
	_array.erase(spec)
	_erase_from_arrays(spec)


func remove_at(spec: AttributeEffectSpec, index: int) -> void:
	_array.remove_at(index)
	_erase_from_arrays(spec)


func _erase_from_arrays(spec: AttributeEffectSpec) -> void:
	if spec.get_effect().is_temporary():
		_only_temps.erase(spec)
	if spec.get_effect().is_blocker():
		_only_blockers.erase(spec)
	if spec.get_effect().is_modifier():
		_only_modifiers.erase(spec)


func is_empty() -> bool:
	return _array.is_empty()


func has(spec: AttributeEffectSpec) -> bool:
	return _array.has(spec)


func has_temps() -> bool:
	return !_only_temps.is_empty()


func has_blockers() -> bool:
	return !_only_blockers.is_empty()


func has_modifiers() -> bool:
	return !_only_modifiers.is_empty()


func clear() -> void:
	_array.clear()
	_only_temps.clear()
	_only_blockers.clear()
	_only_modifiers.clear()
