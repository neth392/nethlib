## Utilities regarding time.
class_name TimeUtil extends Object

enum TimeUnit {
	## Time in seconds.
	SECONDS = 0,
	## Time in milliseconds.
	MILLISECONDS = 1,
	## Time in microseconds.
	MICROSECONDS = 2,
}

static var _conversions_to_seconds: Dictionary = {
	TimeUnit.SECONDS: 1.0,
	TimeUnit.MILLISECONDS: 1_000.0,
	TimeUnit.MICROSECONDS: 1_000_000.0,
}

## Returns the amount of time passed since the engine started, but in the unit of [param time_unit].
static func get_ticks(time_unit: TimeUnit) -> float:
	match time_unit:
		TimeUnit.MICROSECONDS:
			return Time.get_ticks_usec()
		TimeUnit.MILLISECONDS:
			return Time.get_ticks_msec()
		TimeUnit.SECONDS:
			return TimeUtil.get_ticks_seconds()
		_:
			assert(false, "no implementation for time_unit (%s)" % time_unit)
			return false


## Returns the conversion of [method Time.get_ticks_usec] to seconds.
static func get_ticks_seconds() -> float:
	return Time.get_ticks_usec() / 1_000_000.0


## Converts the [param time] of unit [param origin_unit] to seconds.
static func convert_to_seconds(time: float, origin_unit: TimeUnit) -> float:
	assert(_conversions_to_seconds.has(origin_unit), 
	"origin_unit (%s) not in _conversions_to_seconds" % origin_unit)
	return time / _conversions_to_seconds[origin_unit]


## Converts the [param time] of unit [param origin_unit] to the time in [param target_unit].
static func convert_to(time: float, origin_unit: TimeUnit, target_unit: TimeUnit) -> float:
	return convert_to_seconds(time, origin_unit) * _conversions_to_seconds[target_unit]
