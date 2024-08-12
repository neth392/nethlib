## Simple tool useful for testing execution times of code.
@tool
extends Node

## The time the test started at, in seconds.
var started: float

## Starts the test.
func start() -> void:
	started = _get_seconds()

## Prints the amount of time, in seconds, since [method start] was called.
## [br][param prefix] is inserted before the printed string.
## [br][param suffix] is appended to the end of the printed string.
func print_time_taken(prefix: String = "", suffix: String = "",) -> void:
	print(prefix + str(_get_seconds() - started) + suffix)


func _get_seconds() -> float:
	return Time.get_ticks_usec() / 1_000_000.0
