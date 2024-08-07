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


func size() -> int:
	return _array.size()


func update_reversed_range() -> void:
	if _array.size() !=_reversed_range.size():
		_reversed_range = range(_array.size() - 1, -1, -1)


func get_at_index(index: int) -> AttributeEffectSpec:
	return _array[index]


## Adds the [param spec] to this array, returning the index it was added at.[br]
## If [param _update_reverse_range] is true, [method update_reversed_range] will be called.
func add(spec: AttributeEffectSpec, _update_reverse_range: bool = false) -> int:
	_assert_type(spec)
	var added_at_index: int = -1
	for index: int in _array.size():
		if _sort_a_before_b(spec, _array[index]):
			_array.insert(index, spec)
			added_at_index = index
			break
	if added_at_index == -1:
		_array.append(spec)
		added_at_index = _array.size() - 1
	if _update_reverse_range:
		_reversed_range.push_front(_array.size() - 1)
	return added_at_index


func remove_at(index: int, _update_reverse_range: bool = false) -> void:
	_array.remove_at(index)
	if _update_reverse_range:
		_reversed_range.pop_front()


## Returns the reverse range of the array for iteration purposes ONLY.
func iterate_indexes_reverse() -> Array:
	return _reversed_range


func is_empty() -> bool:
	return _array.is_empty()


func clear() -> void:
	_array.clear()
	_reversed_range = []


func for_each(spec_consumer: Callable) -> void:
	for spec: AttributeEffectSpec in _array:
		spec_consumer.call(spec)


func _assert_type(spec: AttributeEffectSpec) -> void:
	assert(_type == spec.get_effect().type, "_type (%s) != to type of spec (%s)" \
	% [_type, spec])
