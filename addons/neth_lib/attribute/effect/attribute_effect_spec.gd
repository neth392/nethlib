## Data class that represents an individual instance of an [AttributeEffect] 
## which was (or can be) applied to an [Attribute].
class_name AttributeEffectSpec extends Resource

## TODO Implement & Document
signal remaining_duration_changed(prev_duration: float)

## TODO Implement & Document
signal stack_count_changed(prev_stack_count: int)

## TODO Implement & Document
signal added(to: Attribute)

## TODO Implement & Document
signal applied(to: Attribute)

## TODO Implement & Document
signal removed(from: Attribute)

## The remaining duration in seconds, can not be set to less than 0.0.
var remaining_duration: float:
	set(_value):
		var previous: float = remaining_duration
		remaining_duration = max(0.0, _value)
		remaining_duration_changed.emit(previous)

## The remaining amount of time, in seconds, until this effect is next triggered.
## Can be manually set before applying to an [Attribute] to create an initial
## delay.
var remaining_period: float = 0.0

var _effect: AttributeEffect
var _initialized: bool = false
var _expired: bool = false
var _is_added: bool = false
var _stack_count: int = 1
var _apply_count: int = 0

var _last_blocked_by: AttributeEffectCondition
var _last_add_result: Attribute.AddEffectResult = Attribute.AddEffectResult.NEVER_ADDED

var _tick_added_on: int = -1
var _tick_last_processed: int = -1
var _tick_last_applied: int = -1

var _active_duration: float = 0.0

var _last_differential: float
var _last_effect_value: float
var _last_applied_value: float
var _last_calculated_value: float


## The last value directly set to the Attribute. Derived from applying the [AttributeEffectCalculator]
## to the Attribute's current value and the [member _last_value_from_effect].
var _last_value_set_to_attribute: float
var _last_value_from_effect: float

var _pending_value: float

func _init(effect: AttributeEffect) -> void:
	assert(effect != null, "effect is null")
	_effect = effect


## Returns the [AttributeEffect] instance this spec was created for.
func get_effect() -> AttributeEffect:
	return _effect


## Whether or not this instance has been initialized by an [Attribute].
## [br]Initialization means that the default duration & initial period have been set
## so this effect can be processed & applied.
func is_initialized() -> bool:
	return _initialized


## De-initializes the spec (only if already initialized), setting [member remaining_period] 
## and [member remaining_duration] to 0.0.
func deinitialize() -> void:
	if is_initialized():
		remaining_period = 0.0
		remaining_duration = 0.0
		_initialized = false


## Returns true if this spec is currently added to an [Attribute].
func is_added() -> bool:
	return _is_added


func get_tick_added_on() -> int:
	return _tick_added_on


## Returns the last tick (see [method Attribute._get_ticks]) this spec was processed on. This
## tick may be unreliable to determine when it was last processed if scene tree pausing has
## been activated, as this is adjusted accordingly.
func get_tick_last_processed() -> int:
	return _tick_last_processed


## Returns the last [method Time.get_ticks_msec] this spec was applied on. -1 if it has not
## yet been applied. Always returns -1 for TEMPORARY effects.
func get_tick_last_applied() -> int:
	return _tick_last_applied


## Returns true if the effect has been applied. Always returns false for
## TEMPORARY effects.
func has_applied() -> bool:
	return _tick_last_applied > -1


## Returns the total amount of duration, in seconds, this spec has been active for.
## [b]NOTE: Includes any time the [Attribute] spent in a paused state.[/b] Use
## [method get_active_duration] to omit the time spent paused.
func get_total_duration() -> float:
	return Attribute._ticks_to_seconds(Attribute._get_ticks() - _tick_added_on)


## Returns total amount of duration, in seconds, this spec has been active for. Does not
## include time that was passed when an [Attribute] was paused.
func get_active_duration() -> float:
	return _active_duration


## Returns the sum of [member remaining_duration] and [method get_active_duration],
## which represents the total amount of time, in seconds, this effect is expected to live for.
func get_active_expected_duration() -> float:
	return remaining_duration + _active_duration


## Returns the last value that was calculated from applying this effect's 
## [AttributeEffectCalculator] on the [Attribute]'s value before, and 
## the [member _last_effect_value].
func get_last_calculated_value() -> float:
	return _last_calculated_value


func get_last_applied_value() -> float:
	return _last_applied_value


## Returns the difference between [method get_last_applied_value] and the [Attribute]'s value before
## the change.
func get_last_differential() -> float:
	return _last_differential


## Returns the value that was last derived from [method AttributeEffect.get_modified_value].
func get_last_effect_value() -> float:
	return _last_effect_value


## Returns the value that is pending, and not yet applied to the [Attribute]. Pending
## means the effect has yet to pass any [AttributeEffectCondition]s that may block it from
## applying to an [Attribute]. This is primarily for use in [AttributeEffectCondition]s.
func get_pending_value() -> float:
	return _pending_value


## If currently blocked, returns the [AttributeEffectCondition] that blocked this spec
## when being added to an effect or in applying. Returns null if not currently blocked.
func get_last_blocked_by() -> AttributeEffectCondition:
	return _last_blocked_by


## Returns the [enum Attribute.AddEffectResult] from the last attempt to add this
## spec to an [Attribute].
func get_last_add_result() -> Attribute.AddEffectResult:
	return _last_add_result


## Amount of times this [AttributeEffectSpec] was applied to an [Attribute]. Does not
## track for TEMPORARY effects, thus the value is always 0 in that case.
func get_apply_count() -> int:
	return _apply_count


## Returns true if [method get_effect] has an apply limit & this spec's [method get_apply_count]
## has either met or exceeded the [member AttributeEffect.apply_limit_amount].
func hit_apply_limit() -> bool:
	return _effect.has_apply_limit() && _apply_count >= _effect.apply_limit_amount


## Returns true if the effect expired due to duration, false if not. Can be useful
## to see if this spec was manually removed from an [Attribute] or if it expired.
func is_expired() -> bool:
	return !_effect.is_instant() && _effect.has_duration() && _expired


## If this effect is stackable.
func is_stackable() -> bool:
	return _effect.stack_mode == AttributeEffect.StackMode.COMBINE


## Returns the stack count (how many [AttributeEffect]s have been stacked).
## Can't be less than 1.
func get_stack_count() -> int:
	return _stack_count


func _initialize(attribute: Attribute) -> void:
	assert(!is_initialized(), "spec already initialized")
	if _effect.has_period() && _effect.initial_period:
		remaining_period = _effect.get_modified_period(attribute, self)
	if _effect.has_duration():
		remaining_duration = _effect.get_modified_duration(attribute, self)
	_initialized = true


## Adds [param amount] to the effect stack. This effect must be stackable
## (see [method is_stackable]) and [param amount] must be > 0.
## [br]Automatically emits [signal Attribute.effect_stack_count_changed].
func _add_to_stack(attribute: Attribute, amount: int = 1) -> void:
	assert(is_stackable(), "_effect (%s) not stackable" % _effect)
	assert(amount > 0, "amount(%s) <= 0" % amount)
	
	var previous_stack_count: int = _stack_count
	_stack_count += amount
	_run_stack_callbacks(attribute, previous_stack_count)
	attribute.effect_stack_count_changed.emit(self, previous_stack_count)


## Removes [param amount] from the effect stack. This effect must be stackable
## (see [method is_stackable]), [param amount] must be > 0, and 
## [method get_stack_count] - [param amount] must be > 0.
## [br]Automatically emits [signal Attribute.effect_stack_count_changed].
func _remove_from_stack(attribute: Attribute, amount: int = 1) -> void:
	assert(is_stackable(), "_effect (%s) not stackable" % _effect)
	assert(amount > 0, "amount(%s) <= 0" % amount)
	assert(_stack_count - amount > 0, "amount(%s) - _stack_count(%s) <= 0"\
		% [amount, _stack_count])
	
	var previous_stack_count: int = _stack_count
	_stack_count -= amount
	_run_stack_callbacks(attribute, previous_stack_count)
	attribute.effect_stack_count_changed.emit(self, previous_stack_count)


## Runs the callback [param _function] on all [AttributeEffectCallback]s who have
## implemented that function.
func _run_callbacks(_function: AttributeEffectCallback._Function, attribute: Attribute) -> void:
	if !AttributeEffectCallback._can_run(_function, _effect):
		return
	var function_name: String = AttributeEffectCallback._function_names[_function]
	for callback: AttributeEffectCallback in _effect._callbacks_by_function.get(_function):
		callback.call(function_name, attribute, self)


func _run_stack_callbacks(attribute: Attribute, previous_stack_count: int) -> void:
	var function_name: String = AttributeEffectCallback._function_names\
	[AttributeEffectCallback._Function.STACK_CHANGED]
	
	for callback: AttributeEffectCallback in _effect._callbacks_by_function\
	.get(AttributeEffectCallback._Function.STACK_CHANGED):
		callback.call(function_name, attribute, self, previous_stack_count)


func _to_string() -> String:
	return "AttributeEffectSpec(_effect.id:%s)" % _effect.id
