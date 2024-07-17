## Callback that allows durations to be stacked when [AttributeEffect]s
## are stacked.
class_name StackDurationCallback extends AttributeEffectCallback

## Determines how [member duration_in_seconds] is modified when an [AttributeEffectSpec]
## is stacked. Only applicable if [member duration_type] is [enum DurationType.HAS_DURATION].
enum Mode {
	## Resets the duration to [method AttributeEffect.calculate_starting_duration] every
	## time the stack is increased.
	RESET,
	## Multiplies [method AttributeEffect.calculate_starting_duration] by the stack count,
	## then adds it to .
	ADD,
	## Divides [member duration_in_seconds] by the stack count.
	SUBTRACT,
}

## Editor tool function that is called when this callback is added to [param effect].
## A good place to write assertions.
func _validate_and_assert(effect: AttributeEffect) -> void:
	assert(effect.stack_mode == AttributeEffect.StackMode.COMBINE,
	"stack_mode != COMBINE for effect: %s" % effect)
