## Causes immediate changes to the remaining duration of an [AttributeEffectSpec]
## when the stack value is changed.
@tool
class_name StackDurationCallback extends AttributeEffectCallback

## Determines how [member duration_in_seconds] is modified when an [AttributeEffectSpec]
## is stacked. Only applicable if [member duration_type] is [enum DurationType.HAS_DURATION].
enum Mode {
	## Does nothing on stacking.
	IGNORE,
	## Resets the duration to [method AttributeEffect.get_modified_duration] regardless
	## of the change in stack count.
	RESET,
	## Determines the difference between the old stack count & new stack count,
	## then muliplities that by [method AttributeEffect.get_modified_duration] and
	## ADDS it to the remaining duration.
	ADD,
	## Determines the difference between the old stack count & new stack count,
	## then muliplities that by [method AttributeEffect.get_modified_duration] and
	## SUBTRACTS it to the remaining duration.
	SUBTRACT,
}

## The [enum Mode] to use for when stack is increased.
@export var increase_mode: Mode

## The [enum Mode] to use for when stack is decreased. Usually IGNORE or the inverse
## of increase mode. For example, if increase_mode is ADD, you may want this to be SUBTRACT.
@export var decrease_mode: Mode

func _run_assertions(effect: AttributeEffect) -> void:
	assert(effect.stack_mode == AttributeEffect.StackMode.COMBINE,
	"stack_mode != COMBINE for effect: %s" % effect)
	assert(effect.duration_type == AttributeEffect.DurationType.HAS_DURATION,
	"duration_type != HAS_DURATION for effect: %s" % effect)
	assert(increase_mode != Mode.IGNORE && decrease_mode != Mode.IGNORE,
	"both increase_mode & decrease_mode are IGNORE; this callback does nothing")


func _stack_changed(attribute: Attribute, spec: AttributeEffectSpec, previous_stack_count: int) -> void:
	if spec.get_stack_count() == previous_stack_count:
		return
	var mode_to_use: Mode = decrease_mode if spec.get_stack_count() < previous_stack_count \
	else increase_mode
	
	var amount: int = abs(spec.get_stack_count() - previous_stack_count)
	
	match mode_to_use:
		Mode.IGNORE:
			pass
		Mode.RESET:
			_reset(attribute, spec)
		Mode.ADD:
			_add(attribute, spec, amount)
		Mode.SUBTRACT:
			_subtract(attribute, spec, amount)
		_:
			assert(false, "no calculations written for mode: %s" % mode_to_use)


func _reset(attribute: Attribute, spec: AttributeEffectSpec) -> void:
	var duration: float = spec._effect.get_modified_duration(attribute, spec)
	spec._starting_duration = duration
	spec.remaining_duration = duration


func _add(attribute: Attribute, spec: AttributeEffectSpec, amount: int) -> void:
	var duplicate: AttributeEffectSpec = spec.duplicate(false)
	## TODO figure this out, manually changing stack count doesn't work
	var previous_stack_count: int = spec._stack_count
	spec._stack_count = amount
	var duration: float = amount * spec._effect.get_modified_duration(attribute, spec)
	spec._starting_duration += duration
	spec.remaining_duration += duration


func _subtract(attribute: Attribute, spec: AttributeEffectSpec, amount: int) -> void:
	var duration: float = amount * spec._effect.get_modified_duration(attribute, spec)
	spec._starting_duration -= duration
	spec.remaining_duration -= duration
