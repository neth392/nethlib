extends Node


var stop: bool = false
var seconds: float

var added: float = -1.0
var added_during_pause: bool = false
var last_process: float

var duration: float = 3.2
var remaining_duration: float = duration
var total_duration_active: float = 0.0

var time_paused: float

func _ready() -> void:
	print("paused? " + str(can_process()))
	get_tree().paused = true
	print("paused? " + str(can_process()))
	return
	get_tree().paused = true
	await _wait(1.0)
	added = _get_seconds()
	added_during_pause = true
	last_process = _get_seconds()
	print("ADDED @ %s" % added)
	await _wait(2.0)
	get_tree().paused = false


func _process(delta: float) -> void:
	return
	if stop || added < 0:
		return
	var current_seconds: float = _get_seconds()
	total_duration_active += current_seconds - last_process
	remaining_duration -= current_seconds - last_process
	if remaining_duration <= 0.0:
		print("REMAINING DURATION <= 0")
		print("TOTAL DURATION ACTIVE: %s" % total_duration_active)
		print("TOTAL TIME ADDED: %s" % str(_get_seconds() - added))
		stop = true
	last_process = _get_seconds()


func _wait(seconds: float) -> void:
	print("WAIT: %s" % seconds)
	await get_tree().create_timer(seconds).timeout


func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		print("PAUSED, can process? " + str(can_process()))
		time_paused = _get_seconds()
	if what == NOTIFICATION_UNPAUSED:
		var seconds: float = _get_seconds()
		# If added during pause, set process time to unpause time
		if added >= time_paused && added <= seconds:
			last_process = seconds
		else: # If added before pause, add pause duration to process time
			var pause_duration: float = seconds - time_paused
			print("UN-PAUSED, can process? %s, pause_duration: %s" % [can_process(), pause_duration])
			last_process += pause_duration


func _get_seconds() -> float:
	return float(Time.get_ticks_usec()) / 1_000_000
