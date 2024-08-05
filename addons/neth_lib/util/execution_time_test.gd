@tool
extends Node

var started: float

func start() -> void:
	started = _get_seconds()


func print_time_taken(prefix: String = "") -> void:
	print(prefix + str(_get_seconds() - started))


func _get_seconds() -> float:
	return Time.get_ticks_usec() / 1_000_000.0
