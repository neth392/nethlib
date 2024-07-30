@tool
extends Node

var started: float

func start() -> void:
	started = _get_ticks_msec()


func print_time_taken(prefix: String = "") -> void:
	print(prefix + str(_get_ticks_msec() - started))


func _get_ticks_msec() -> float:
	return Time.get_ticks_usec() / 1000.0
