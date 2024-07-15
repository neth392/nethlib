class_name AttributeEffectSpec extends Resource

static func compare(a: AttributeEffectSpec, b: AttributeEffectSpec) -> bool:
	var a_override: bool = a.is_override()
	var b_override: bool = b.is_override()
	
	if a_override && b_override:
		return a._effect.override_priority > b._effect.override_priority
	elif a_override:
		return true
	else:
		return false

## The effect this [AttributeEffectSpec] was created for.
var _effect: AttributeEffect

## The current stack count
var _stack_count: int

## If true, duration is ticking (if the [AttributeEffect] has a duration).
var tick_duration: bool = true

## The initial duration of the effect.
var _starting_duration: float

## The remaining duration in seconds, can not be set to less than 0.0.
var remaining_duration: float:
	set(_value):
		remaining_duration = max(0.0, _value)

var _is_active: bool = false

var _last_denied_by: AttributeEffectCondition

## The remaining amount of time, in seconds, until this effect is next triggered.
var remaining_period: float = 0.0

func _init(effect: AttributeEffect, stack_count: int = 1) -> void:
	assert(effect != null, "effect is null")
	assert(stack_count > 0, "stack_count is > 0")
	assert(stack_count < 2 || effect.stack_mode == AttributeEffect.StackMode.COMBINE,
	"stack_count >= 2 but stack_mode = false for effect: (%s)" % effect)
	_effect = effect
	_stack_count = stack_count


## Returns the [AttributeEffect] instance this spec was created for.
func get_effect() -> AttributeEffect:
	return _effect


## Returns true if this [AppliedAttributeEffect] is active, false if not.
func is_active() -> bool:
	return _is_active


## Returns true if [member effect] has a [member AttributeEffect.value_calc_type]
## equal to [enum AttributeEffect.ValueCalcType.OVERRIDE]
func is_override() -> bool:
	return _effect.value_cacl_type == AttributeEffect.ValueCalcType.OVERRIDE


## Returns the last [AttributeEffectCondition] that denied this [AttributeEffectSpec].
func get_last_denied_by() -> AttributeEffectCondition:
	return _last_denied_by


## Returns the initial duration of the effect when it was first applied.
func get_starting_duration() -> float:
	return _starting_duration


## Calculates the value to be used at the current frame.
func calculate_value(attribute: Attribute) -> float:
	return _effect._calculate_value(attribute, self)
