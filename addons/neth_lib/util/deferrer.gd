## The Deferrer node provides a mechanism to defer the execution of Callable functions until a 
## lock is released. It allows accumulating the queuing of actions while the system is "locked" and 
## then automatically executes them in the order they were added once unlocked. There is an
## internal lock count so a single deferrer can be used in nested callables.
## [br]The benefit of this over Godot's own call_deferred is that code is executed immediately
## after the deferrer's owner system is done with its sensitive operations, and the deferred callables
## do not have to wait for the engine to have idle time.
class_name Deferrer extends Node

var _lock_count: int = 0:
	set(value):
		assert(value >= 0, "_lock_count can't be < 0")
		_lock_count = value

var _deferred: Array[Callable] = []


## Defers the exuecution of the [param callable] until this deferrer is unlocked.
func defer(callable: Callable) -> void:
	assert(is_locked(), "Deferrer not locked, no need to use defer")
	_deferred.push_front(callable)


## Returns the internal lock count.
func get_lock_count() -> int:
	return _lock_count


## Returns true if the internal lock count is > 0, false if not.
func is_locked() -> bool:
	return _lock_count > 0


## Adds 1 to the internal lock counter
func lock() -> void:
	_lock_count += 1


## Subtracts one from the internal lock counter. If the new lock count is zero,
## all [Callable]s added via [method defer] are immediately executed in the order
## they were received.
func unlock() -> void:
	_lock_count -= 1
	if _lock_count == 0:		
		var callable: Callable = _deferred.pop_back()
		while callable != null:
			callable.call()
			callable = _deferred.pop_back()
