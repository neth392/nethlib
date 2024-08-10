extends Node


var seconds: float
var time_paused: float

func _ready() -> void:
	print("SECONDS: " + str(_get_seconds()))
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false
	
	#ExecutionTimeTest.start()
	#ExecutionTimeTest.print_time_taken("1")
	#
	#ExecutionTimeTest.start()
	#ExecutionTimeTest.print_time_taken("2")



func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		print("PAUSED")
		time_paused = _get_seconds()
	if what == NOTIFICATION_UNPAUSED:
		print("UN-PAUSED")


func _get_seconds() -> float:
	return Time.get_ticks_usec() / 1_000_000
