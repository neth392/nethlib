## Data class that represents a seperate instance of an [AttributeEffect] 
## which was (or can be) applied to an [Attribute].
class_name AttributeEffectSpec extends Resource

## Helper function that calls [method AttributeEffect.sort_ascending] from the
## [member _effect] of each [param a] and [param b].
static func sort_ascending(a: AttributeEffectSpec, b: AttributeEffectSpec) -> bool:
	return AttributeEffect.sort_ascending(a._effect, b._effect)


## The remaining duration in seconds, can not be set to less than 0.0.
var remaining_duration: float:
	set(_value):
		remaining_duration = max(0.0, _value)

## The remaining amount of time, in seconds, until this effect is next triggered.
## Can be manually set before applying to an [Attribute] to create an initial
## delay.
var remaining_period: float = 0.0

## If this spec has been initialized by an [Attribute].
var _initialized: bool = false

## The amount of time, in seconds, of how long this effect has been active
var _passed_duration: float = 0.0

## The effect this [AttributeEffectSpec] was created for.
var _effect: AttributeEffect

## The current stack count
var _stack_count: int = 1

## If this spec is actively added to an [Attribute].
var _is_added: bool = false

## If this spec is actively added to an [Attribute] & processing is not
## blocked by an [AttributeEffectCondition].
var _is_processing: bool = false

## Amount of times the [AttributeEffect] was applied to the [Attribute].
var _apply_count: int = 0

## The condition that lasts blocks addition or application of this spec.
var _last_blocked_by: AttributeEffectCondition

## The last frame this spec was processed on. If the value is -1, this
## spec has not yet been processed.
var _last_process_frame: int = -1

## The last frame this spec was applied on. If the value is -1, this spec
## has not yet been applied.
var _last_apply_frame: int = -1

## The last value that was set to [member Attribute.value] based on the
## [enum AttributeEffect.ValueCalcType].
var _last_set_value: float

## The value that was last derived from [method AttributeEffect.get_modified_value].
## This does NOT take into account the [enum AttributeEffect.ValueCalcType] of the
## effect.
var _last_value: float

## Whether or not this spec expired.
var _expired: bool = false

func _init(effect: AttributeEffect) -> void:
	assert(effect != null, "effect is null")
	_effect = effect


## Returns the [AttributeEffect] instance this spec was created for.
func get_effect() -> AttributeEffect:
	return _effect


## Whether or not this instance has been initialized by an [Attribute].
## [br]Initialization means that the default duration, period, & all other
## necessary properties have been set so this effect can be processed & applied.
func is_initialized() -> bool:
	return _initialized


## Returns true if this spec is currently added to an [Attribute].
func is_added() -> bool:
	return _is_added


## Returns true if this spec is currently added to an [Attribute] AND
## processing has not been blocked by an [AttributeEffectCondition].
func is_processing() -> bool:
	return _is_processing


## Returns the last process frame this spec was processed on. -1 if it has not
## yet been processed.
func get_last_process_frame() -> int:
	return _last_process_frame


## Returns true if the effect has been processed.
func has_processed() -> bool:
	return _last_process_frame > -1


## Returns the last process frame this spec was applied on. -1 if it has not
## yet been applied. Always returns -1 for TEMPORARY effects.
func get_last_apply_frame() -> int:
	return _last_apply_frame


## Returns true if the effect has been applied. Always returns false for
## TEMPORARY effects.
func has_applied() -> bool:
	return _last_apply_frame > -1


## Returns the last value that was directly set to the [Attribute], either
## current (for temporary effects) or base value (for permanent effects)
func get_last_set_value() -> float:
	return _last_set_value


## Returns the value that was last derived from [method AttributeEffect.get_modified_value].
## This does NOT take into account the [AttributeEffectCalculator].
func get_last_value() -> float:
	return _last_value


## If currently blocked, returns the [AttributeEffectCondition] that blocked this spec
## when being added to an effect, in processing, or in applying. Returns null if not
## currently blocked.
func get_last_blocked_by() -> AttributeEffectCondition:
	return _last_blocked_by


## Returns the amount of time, in seconds, this effect has been active for.
func get_passed_duration() -> float:
	return _passed_duration


## Returns the total [b]expected[/b] duration (passed + remaining) in seconds. If this
## effect is infinite, this returns the same as [method get_passed_duration].
func get_total_duration() -> float:
	return _passed_duration + remaining_duration


## Amount of times this [AttributeEffectSpec] was applied to an [Attribute].
func get_apply_count() -> int:
	return _apply_count


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


## Checks if there is an [AttributeEffectCondition] blocking the processing of this
## spec on [param attribute]. Returns the condition that is blocking it, or
## null if there is no blocking condition. Also returns null if the effect
## is temporary or instant (doesn't support process conditions).
func _can_process(attribute: Attribute) -> AttributeEffectCondition:
	if !_effect.has_process_conditions():
		return null
	return _check_conditions(attribute, _effect.process_conditions)


## Checks if there is an [AttributeEffectCondition] blocking the addition of this
## spec to the [param attribute]. Returns the condition that is blocking it, or
## null if there is no blocking condition.
func _can_add(attribute: Attribute) -> AttributeEffectCondition:
	return _check_conditions(attribute, _effect.add_conditions)


## Checks if there is an [AttributeEffectCondition] blocking the application of this
## spec to the [param attribute]. Returns the condition that is blocking it, or
## null if there is no blocking condition. Also returns null if the effect
## is temporary (doesn't support apply conditions).
func _can_apply(attribute: Attribute) -> AttributeEffectCondition:
	if !_effect.has_apply_conditions():
		return null
	return _check_conditions(attribute, _effect.apply_conditions)


func _check_conditions(attribute: Attribute, conditions: Array[AttributeEffectCondition]) \
 -> AttributeEffectCondition:
	for condition: AttributeEffectCondition in conditions:
		if !condition.meets_condition(attribute, self):
			return condition
	return null


## Runs the callback [param _function] on all [AttributeEffectCallback] who have
## implemented that function.
func _run_callbacks(_function: AttributeEffectCallback._Function, attribute: Attribute) -> void:
	if !AttributeEffectCallback._can_run(_function, _effect):
		return
	var function_name: String = AttributeEffectCallback._functions_by_name[_function]
	for callback: AttributeEffectCallback in _effect._callbacks_by_function.get(_function):
		callback.call(function_name, attribute, self)


func _run_stack_callbacks(attribute: Attribute, previous_stack_count: int) -> void:
	var function_name: String = AttributeEffectCallback._functions_by_name\
	[AttributeEffectCallback._Function.STACK_CHANGED]
	
	for callback: AttributeEffectCallback in _effect._callbacks_by_function\
	.get(AttributeEffectCallback._Function.STACK_CHANGED):
		callback.call(function_name, attribute, self, previous_stack_count)


func _to_string() -> String:
	return "AttributeEffectSpec(_effect.id:%s)" % _effect.id
