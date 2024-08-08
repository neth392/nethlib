## Manages two [AttributeEffectSpecArray]s, one for temporary specs and one for permanent specs.
## For use with iterating over all specs at once. Temporary specs are ordered before permanent
## specs, and specs with the least priority are before those with greater priority.
class_name AttributeEffectSpecCluster extends Resource

static func _sort_a_before_b(a: AttributeEffectSpec, b: AttributeEffectSpec) -> bool:
	if a.get_effect().type != b.get_effect().type:
		return a.get_effect().type == AttributeEffect.Type.PERMANENT
	return a.get_effect().apply_priority >= b.get_effect().apply_priority

var _reversed_range: Array
var _array: Array[AttributeEffectSpec] = []


func _init(default_specs: Array[AttributeEffectSpec] = []) -> void:
	assert(!default_specs.has(null), "default_specs has null element")
	for spec: AttributeEffectSpec in default_specs:
		add(spec)


#func size() -> int:
	#return _array.size()


## Returns the underlying array for iteration purposes ONLY.
func iterate() -> Array[AttributeEffectSpec]:
	return _array


## Adds the [param spec] to the internal [AttributeEffectSpecArray] of it's [member Attribute.type].
## Returns the spec's new index in this cluster.[br]
## If [param _update_reverse_range] is true, [method update_reverse_range] is called.
func add(spec_to_add: AttributeEffectSpec) -> void:
	assert(!_array.has(spec_to_add), "spec_to_add (%s) already present" % spec_to_add)
	var index: int = 0
	for spec: AttributeEffectSpec in _array:
		if _sort_a_before_b(spec_to_add, spec):
			_array.insert(index, spec_to_add)
			return
		index += 1
	_array.append(spec_to_add)


func erase(spec: AttributeEffectSpec) -> void:
	_array.erase(spec)


#func is_empty() -> bool:
	#return _array.is_empty()


func has(spec: AttributeEffectSpec) -> bool:
	return _array.has(spec)


func clear() -> void:
	_array.clear()
