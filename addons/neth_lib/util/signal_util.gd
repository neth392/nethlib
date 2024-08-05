## Utilities for [Signal]s.
@tool
class_name SignalUtil extends Object


## Connects the [param _signal] to the [param _callable] if the signal is
## not already connected to the callable. If either value is null nothing happens.[br]
## Returns true if the signal was connected, false if not.
static func connect_safely(_signal: Signal, _callable: Callable) -> bool:
	assert(_callable.is_valid(), "_callable (%s) not valid" % _callable)
	assert(!_signal.is_null(), "_signal (%s) is null" % _signal)
	if !_signal.is_connected(_callable):
		_signal.connect(_callable)
		return true
	
	return false


## Disconnects the [param _signal] from the [param _callable] if the signal is
## connected to it. If either value is null nothing happens.[br]
## Returns true if the signal was disconnected, false if not.
static func disconnect_safely(_signal: Signal, _callable: Callable) -> bool:
	assert(_callable.is_valid(), "_callable (%s) not valid" % _callable)
	assert(!_signal.is_null(), "_signal (%s) is null" % _signal)
	if _signal.is_connected(_callable):
		_signal.disconnect(_callable)
		return true
	
	return false
