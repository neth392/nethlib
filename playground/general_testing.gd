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


# SCENARIOS TO TRY:
# - spec added during normal processing
# - 

func _ready() -> void:
	get_tree().paused = true
	await _wait(1.0)
	added = _get_seconds()
	added_during_pause = true
	last_process = _get_seconds()
	print("ADDED @ %s" % added)
	await _wait(2.0)
	get_tree().paused = false


func _process(delta: float) -> void:
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
		print("PAUSED")
		time_paused = _get_seconds()
	if what == NOTIFICATION_UNPAUSED:
		var seconds: float = _get_seconds()
		# If added during pause, set process time to unpause time
		if added >= time_paused && added <= seconds:
			last_process = seconds
		else: # If added before pause, add pause duration to process time
			var pause_duration: float = seconds - time_paused
			print("UN-PAUSED, pause_duration: %s" % pause_duration)
			last_process += pause_duration


func is_paused(node: Node) -> bool:
	var paused: bool = get_tree().paused
	match node.process_mode:
		PROCESS_MODE_ALWAYS:
			return false
		PROCESS_MODE_DISABLED:
			return true
		PROCESS_MODE_INHERIT:
			if node.get_parent() == null || get_tree().root == node:
				return paused
			return is_paused(node.get_parent())
		PROCESS_MODE_PAUSABLE:
			return paused
		PROCESS_MODE_WHEN_PAUSED:
			return !paused
		_: # Should never reach this point
			assert(false, "Unknown process_mode (%s) for Node (%s)" % [node.process_mode, node])
			return false


func _get_seconds() -> float:
	return float(Time.get_ticks_usec()) / 1_000_000
