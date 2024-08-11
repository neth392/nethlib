extends Node


var stop: bool = false
var seconds: float

var added: float
var last_process: float

var duration: float = 3.2
var remaining_duration: float = duration

var time_paused: float

func _ready() -> void:
	time_added = _get_seconds()
	last_process = _get_seconds()
	print("ADDED")
	get_tree().paused = true
	_wait(2.0)
	get_tree().paused = false


func _process(delta: float) -> void:
	if stop:
		return
	var current_seconds: float = _get_seconds()
	remaining_duration -= current_seconds - last_process
	if remaining_duration <= 0.0:
		print("REMAINING DURATION <= 0")
		print("TOTAL TIME ADDED: %s" % (_get_seconds() - time_added))
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
		var adjustment: 
		print("UN-PAUSED")


func _get_seconds() -> float:
	return float(Time.get_ticks_usec()) / 1_000_000
