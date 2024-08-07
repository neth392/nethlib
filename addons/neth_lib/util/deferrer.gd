class_name Deferrer extends Node

# TODO test if this will work when setting locked & unlocked along with nested calls
# to defer
@export var locked: bool = false:
	set(value):
		if locked != value:
			locked = value
			if !locked:
				var callable: Callable = _deferred.pop_back()
				while callable != null:
					callable.call()
					callable = _deferred.pop_back()

var _deferred: Array[Callable] = []

func defer(callable: Callable) -> void:
	assert(locked, "Deferrer not locked, no need to use defer")
	_deferred.append(callable)
