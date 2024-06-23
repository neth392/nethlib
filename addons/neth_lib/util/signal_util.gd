## Utilities for [Signal]s.
@tool
class_name SignalUtil extends Object


## Connects the [param _signal] to the [param _callable] if the signal is
## not already connected to the callable.
static func connect_safely(_signal: Signal, _callable: Callable) -> void:
	if !_signal.is_connected(_callable):
		_signal.connect(_callable)


## Disconnects the [param _signal] from the [param _callable] if the signal is
## connected to it.
static func disconnect_safely(_signal: Signal, _callable: Callable) -> void:
	if _signal.is_connected(_callable):
		_signal.disconnect(_callable)
