## Wrapper of an [Array] of [AttributeEffectSpec]s for safety in use with an [Attribute].
class_name AttributeEffectSpecArray extends Resource

var _same_priority_sorting_method: Attribute.SamePrioritySortingMethod
var _array: Array[AttributeEffectSpec] = []
var _temp_count: int = 0:
	set(value):
		assert(value >= 0, "_temp_count can't be < 0")
		_temp_count = value
var _blocker_count: int = 0:
	set(value):
		assert(value >= 0, "_blocker_count can't be < 0")
		_blocker_count = value

func _init(same_priority_sorting_method: Attribute.SamePrioritySortingMethod) -> void:
	_same_priority_sorting_method = same_priority_sorting_method
	

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
	return new.get_effect().priority >= other.get_effect().priority


## Returns the underlying array for iteration purposes ONLY.
func iterate() -> Array[AttributeEffectSpec]:
	return _array


func iterate_reverse() -> Array:
	return range(_array.size() -1, -1, -1)


func add(spec_to_add: AttributeEffectSpec) -> int:
	assert(!_array.has(spec_to_add), "spec_to_add (%s) already present" % spec_to_add)
	var index: int = 0
	for spec: AttributeEffectSpec in _array:
		if _sort_new_before_other(spec_to_add, spec):
			_array.insert(index, spec_to_add)
			break
		index += 1
	
	# Append if not added during loop
	if index == _array.size():
		_array.append(spec_to_add)
	
	# Increment temp or blocker count if necessary
	match spec_to_add.get_effect().type:
		AttributeEffect.Type.TEMPORARY:
			_temp_count += 1
		AttributeEffect.Type.BLOCKER:
			_blocker_count += 1
	
	return index


func erase(spec: AttributeEffectSpec) -> void:
	_array.erase(spec)
	match spec.get_effect().type:
		AttributeEffect.Type.TEMPORARY:
			_temp_count -= 1
		AttributeEffect.Type.BLOCKER:
			_blocker_count -= 1


func remove_at(spec: AttributeEffectSpec, index: int) -> void:
	_array.remove_at(index)
	match spec.get_effect().type:
		AttributeEffect.Type.TEMPORARY:
			_temp_count -= 1
		AttributeEffect.Type.BLOCKER:
			_blocker_count -= 1


func is_empty() -> bool:
	return _array.is_empty()


func has(spec: AttributeEffectSpec) -> bool:
	return _array.has(spec)


func has_temp() -> bool:
	return _temp_count > 0


func has_blockers() -> bool:
	return _blocker_count > 0


func clear() -> void:
	_array.clear()
