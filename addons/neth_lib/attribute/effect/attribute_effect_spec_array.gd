## Wrapper of an [Array] of [AttributeEffectSpec]s for safety in use with an [Attribute].
class_name AttributeEffectSpecArray extends Resource

static var _seperate_types: Array[AttributeEffect.Type] = [
	AttributeEffect.Type.BLOCKER,
	AttributeEffect.Type.MODIFIER,
	AttributeEffect.Type.TEMPORARY,
]

var _same_priority_sorting_method: Attribute.SamePrioritySortingMethod
var _array: Array[AttributeEffectSpec] = []

var _by_type: Dictionary = {}


func _init(same_priority_sorting_method: Attribute.SamePrioritySortingMethod) -> void:
	_same_priority_sorting_method = same_priority_sorting_method
	for type: AttributeEffect.Type in _seperate_types:
		_by_type[type] = []


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


## Returns the underlying array for iteration purposes ONLY.
func iterate() -> Array[AttributeEffectSpec]:
	return _array


## Returns an internal array containing all [AttributeEffectSpec]s of the [param type], for
## iteration purposes ONLY.
func iterate_type(type: AttributeEffect.Type) -> Array[AttributeEffectSpec]:
	assert(_by_type.has(type), "type (%s) not found in _by_type")
	return _by_type[type]


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
	
	# Add to typed array if needed
	if spec_to_add.get_effect().type != AttributeEffect.Type.PERMANENT:
		var type_index: int = 0
		var type_array: Array[AttributeEffectSpec] = _by_type[spec_to_add.get_effect().type]
		for spec: AttributeEffectSpec in type_array:
			if _sort_new_before_other(spec_to_add, spec):
				type_array.insert(type_index, spec_to_add)
				break
			type_index += 1
		
		# Append if not added during loop
		if type_index == type_array.size():
			type_array.append(spec_to_add)
	
	return index


func erase(spec: AttributeEffectSpec) -> void:
	_array.erase(spec)
	if spec.get_effect().type != AttributeEffect.Type.PERMANENT:
		_by_type[spec.get_effect().type].erase(spec)


func remove_at(spec: AttributeEffectSpec, index: int) -> void:
	_array.remove_at(index)
	if spec.get_effect().type != AttributeEffect.Type.PERMANENT:
		_by_type[spec.get_effect().type].erase(spec)


func is_empty() -> bool:
	return _array.is_empty()


func has(spec: AttributeEffectSpec) -> bool:
	return _array.has(spec)


#func has_temp() -> bool:
	#return _temp_count > 0
#
#
#func has_blockers() -> bool:
	#return _blocker_count > 0


func clear() -> void:
	_array.clear()
