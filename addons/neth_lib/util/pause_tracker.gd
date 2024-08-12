## Used to track the pausing of the parent [Node] of this node.
@tool
class_name PauseTracker extends Node

## Emitted when the node is paused.
signal paused()

## Emitted when the node is unpaused, [param ticks_paused] is the amount of time
## the node was paused for, based on [enum TimeUnit]
signal unpaused(time_paused: float)

## The [enum TimeUtil.TimeUnit] used in the [param time_paused] parameter of 
## [signal unpaused].
@export var time_unit: TimeUtil.TimeUnit:
	set(value):
		var prev_unit: TimeUtil.TimeUnit = time_unit
		time_unit = value
		if !Engine.is_editor_hint() && prev_unit != time_unit:
			_paused_at = TimeUtil.convert_to(_paused_at, prev_unit, time_unit)

## The time, since the engine began, at which the node was paused at. If it was paused
## at creation, this time represents the creation time.
var _paused_at: float

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if !can_process():
		_paused_at = TimeUtil.get_ticks(time_unit)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if get_parent() == null:
		warnings.append("no parent found")
	if process_mode != PROCESS_MODE_INHERIT:
		warnings.append("process_mode must be PROCESS_MODE_INHERIT for this node to detect the " + \
		"parent pause state")
	return warnings


func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		_paused_at = TimeUtil.get_ticks(time_unit)
		paused.emit()
	if what == NOTIFICATION_UNPAUSED:
		var time_paused: float = TimeUtil.get_ticks(time_unit) - _paused_at
		unpaused.emit(time_paused)


## Returns the time the node was paused at, in the unit of [member time_unit].
func get_paused_at() -> float:
	return _paused_at
