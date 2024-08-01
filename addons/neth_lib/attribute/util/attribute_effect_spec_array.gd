## Manages an array of [AttributEffectSpec]s.
class_name AttributeEffectSpecArray extends Resource

static func _sort_a_before_b(a: AttributeEffectSpec, b: AttributeEffectSpec) -> bool:
	return a.get_effect().apply_priority < b.get_effect().apply_priority


var _type: AttributeEffect.Type
var _reversed_range: Array
var _array: Array[AttributeEffectSpec]


func _init(type: AttributeEffect.Type = -1, internal_array: Array[AttributeEffectSpec] = []) -> void:
	_type = type
	if OS.is_debug_build():
		for element: AttributeEffectSpec in internal_array:
			_assert_type(element)
	_array = internal_array
	_array.sort()


func get_type() -> AttributeEffect.Type:
	return _type


func update_reversed_range() -> void:
	_reversed_range = range(_array.size() - 1, -1, -1)


func get_at_index(index: int) -> AttributeEffectSpec:
	return _array[index]


func add(spec: AttributeEffectSpec, _update_reverse_range: bool = false) -> void:
	_assert_type(spec)
	var _added: bool = false
	for index: int in _array.size():
		if _sort_a_before_b(spec, _array[index]):
			_array.insert(index, spec)
			_added = true
			break
	if !_added:
		_array.append(spec)
	if _update_reverse_range:
		_reversed_range.push_front(_array.size() - 1)


func remove_at_index(index: int, _update_reverse_range: bool = false) -> void:
	_array.remove_at(index)
	if _update_reverse_range:
		_reversed_range.pop_front()


## Returns the reverse range of the array for iteration purposes ONLY.
func iterate_indexes_reverse() -> Array:
	return _reversed_range


func clear() -> void:
	_array.clear()
	_reversed_range = []


func _assert_type(spec: AttributeEffectSpec) -> void:
	assert(_type == spec.get_effect().type, "_type (%s) != to type of spec (%s)" \
	% [_type, spec])
