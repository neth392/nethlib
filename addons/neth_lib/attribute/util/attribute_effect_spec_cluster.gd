## Manages two [AttributeEffectSpecArray]s, one for temporary specs and one for permanent specs.
## For use with iterating over all specs at once. Temporary specs are ordered before permanent
## specs, and specs with the least priority are before those with greater priority.
class_name AttributeEffectSpecCluster extends Resource

var _reversed_range: Array
var _temp_specs: AttributeEffectSpecArray
var _perm_specs: AttributeEffectSpecArray


func _init(default_specs: Array[AttributeEffectSpec] = []) -> void:
	_temp_specs = AttributeEffectSpecArray.new(AttributeEffect.Type.TEMPORARY)
	_perm_specs = AttributeEffectSpecArray.new(AttributeEffect.Type.PERMANENT)
	if !default_specs.is_empty():
		for spec: AttributeEffectSpec in default_specs:
			add(spec, false)
		update_reversed_range()


func size() -> int:
	return _temp_specs.size() + _perm_specs.size()


func update_reversed_range() -> void:
	_perm_specs.update_reversed_range()
	_temp_specs.update_reversed_range()
	_reversed_range = range(size() - 1, -1, -1)


func get_at_index(index: int) -> AttributeEffectSpec:
	assert(index in _reversed_range, "index out of bounds for array size" % size())
	return _get_array_from_index(index).get_at_index(_get_true_index(index))


func add(spec: AttributeEffectSpec, _update_reverse_range: bool = false) -> void:
	_get_array_from_spec(spec).add(spec, _update_reverse_range)
	if _update_reverse_range:
		_reversed_range.push_front(size() - 1)


func remove_at(index: int, _update_reverse_range: bool = false) -> void:
	assert(index in _reversed_range, "index out of bounds for array size" % size())
	_get_array_from_index(index).remove_at(_get_true_index(index), _update_reverse_range)
	if _update_reverse_range:
		_reversed_range.pop_front()


## Returns the reverse range of the array for iteration purposes ONLY.
func iterate_indexes_reverse() -> Array:
	return _reversed_range


func is_empty() -> bool:
	return _temp_specs.is_empty() && _perm_specs.is_empty()


func has(spec: AttributeEffectSpec) -> bool:
	return _get_array_from_spec(spec).has(spec)


func clear() -> void:
	_temp_specs.clear()
	_perm_specs.clear()
	_reversed_range = []


func _get_true_index(index: int) -> int:
	assert(index in _reversed_range, "index out of bounds for array size" % size())
	if index < _temp_specs.size():
		return index
	else:
		return index - _temp_specs.size()


func _get_array_from_index(index: int) -> AttributeEffectSpecArray:
	assert(index in _reversed_range, "index out of bounds for array size" % size())
	if index < _temp_specs.size():
		return _temp_specs
	else:
		return _perm_specs


func _get_array_from_spec(spec: AttributeEffectSpec) -> AttributeEffectSpecArray:
	match spec.get_effect().type:
		AttributeEffect.Type.PERMANENT:
			return _perm_specs
		AttributeEffect.Type.TEMPORARY:
			return _temp_specs
		_:
			assert(false, "no array for spec.get_effect().type (%s)" \
			% spec.get_effect().type)
			return null
