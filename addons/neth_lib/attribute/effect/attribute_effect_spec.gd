## Data class that represents a seperate instance of an [AttributeEffect] 
## which was (or can be) applied to an [Attribute].
class_name AttributeEffectSpec extends Resource

## Used in [method Array.custom_sort] to sort specs in a reverse order.
static func reverse_compare(a: AttributeEffectSpec, b: AttributeEffectSpec) -> bool:
	return a._effect.priority < b._effect.priority

## The remaining duration in seconds, can not be set to less than 0.0.
var remaining_duration: float:
	set(_value):
		remaining_duration = max(0.0, _value)

## The remaining amount of time, in seconds, until this effect is next triggered.
## Can be manually set before applying to an [Attribute] to create an initial
## delay.
var remaining_period: float = 0.0

## The current duration of how long this effect has been active
var _current_duration: float

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
var _blocked_by: AttributeEffectCondition

## The last frame this spec was processed on. If the value is -1, this
## spec has not yet been processed.
var _last_process_frame: int = -1

## The last frame this spec was applied on. If the value is -1, this spec
## has not yet been applied.
var _last_apply_frame: int = -1

## 
var _last_set_value: float

## The value that was last applied.
var _last_applied_value: float

## Whether or not this spec expired.
var _expired: bool = false

func _init(effect: AttributeEffect) -> void:
	assert(effect != null, "effect is null")
	_effect = effect


## Returns the [AttributeEffect] instance this spec was created for.
func get_effect() -> AttributeEffect:
	return _effect


## Shorthand function that returns true [method get_effect] has a 
## [member Attribute.duration_type] of [enum AttributeEffect.DurationType.INSTANT].
func is_instant() -> bool:
	return _effect.duration_type == AttributeEffect.DurationType.INSTANT


## Shorthand function that returns true [method get_effect] has a 
## [member Attribute.duration_type] of [enum AttributeEffect.DurationType.HAS_DURATION].
func has_duration() -> bool:
	return _effect.duration_type == AttributeEffect.DurationType.HAS_DURATION


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
## yet been applied.
func get_last_apply_frame() -> int:
	return _last_apply_frame


## Returns true if the effect has been applied.
func has_applied() -> bool:
	return _last_apply_frame > -1


## The value that was last applied to the [Attribute].
func get_last_applied_value() -> float:
	return _last_applied_value


## Returns true if [member effect] has a [member AttributeEffect.value_calc_type]
## equal to [enum AttributeEffect.ValueCalcType.OVERRIDE]
func is_override() -> bool:
	return _effect.value_cacl_type == AttributeEffect.ValueCalcType.OVERRIDE


## If currently blocked, returns the [AttributeEffectCondition] that blocked this spec.
## Otherwise returns null.
func get_blocked_by() -> AttributeEffectCondition:
	return _blocked_by


## Returns the total current duration of how long, in seconds, this effect has been active.
func get_current_duration() -> float:
	return _current_duration


## Amount of times this [AttributeEffectSpec] was applied to an [Attribute].
func get_apply_count() -> int:
	return _apply_count


## Returns true if the effect expired due to duration, false if not. Can be useful
## to see if this spec was manually removed from an [Attribute] or if it expired.
func expired() -> bool:
	return _expired


func is_stackable() -> bool:
	return _effect.stack_mode == AttributeEffect.StackMode.COMBINE


## Returns the stack count (how many [AttributeEffect]s have been stacked).
## Can't be less than 1.
func get_stack_count() -> int:
	return _stack_count


func add_to_stack(attribute: Attribute, amount: int = 1) -> void:
	assert(is_stackable(), "_effect (%s) not stackable" % _effect)
	assert(amount > 0, "amount(%s) <= 0" % amount)
	
	var previous_stack_count: int = _stack_count
	_stack_count += amount
	_run_stack_callbacks(attribute, previous_stack_count)
	attribute.effect_stack_count_changed.emit(self, previous_stack_count)


func remove_from_stack(attribute: Attribute, amount: int = 1) -> void:
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
## null if there is no blocking condition.
func can_process(attribute: Attribute) -> AttributeEffectCondition:
	return _check_conditions(attribute, _effect._process_conditions)


## Checks if there is an [AttributeEffectCondition] blocking the addition of this
## spec to the [param attribute]. Returns the condition that is blocking it, or
## null if there is no blocking condition.
func can_add(attribute: Attribute) -> AttributeEffectCondition:
	return _check_conditions(attribute, _effect._add_conditions)


## Checks if there is an [AttributeEffectCondition] blocking the application of this
## spec to the [param attribute]. Returns the condition that is blocking it, or
## null if there is no blocking condition.
func can_apply(attribute: Attribute) -> AttributeEffectCondition:
	return _check_conditions(attribute, _effect._apply_conditions)


func _check_conditions(attribute: Attribute, conditions: Array[AttributeEffectCondition]) \
 -> AttributeEffectCondition:
	for condition: AttributeEffectCondition in conditions:
		if !condition.meets_condition(attribute, self):
			return condition
	return null


## Runs the callback [param _function] on all [AttributeEffectCallback] who have
## implemented that function.
func _run_callbacks(_function: AttributeEffectCallback._Function, attribute: Attribute) -> void:
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
