## Represents a state member of a [StateMachine].[br]
## All processing, handled/unhandled inputs are disabled unless the state is active.
@tool
class_name State extends Node

## Emitted by this [State] to notify the [StateMachine] that a transition
## to another [State] is requested. Should not be emitted manually, instead
## use [method request_transition]
signal _transition_requested(target_state: State, data: Variant)

## Internal variable used to block transitions in _state_exited
var _block_transitions: bool = false

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if !(get_parent() is StateMachine):
		warnings.append("Must be a child of a StateMachine")
	
	return warnings


## Call to request a transition out of this [State] to another [State] at the
## [param target_state_path]. [param data] is an optional data variant that
## will be sent to the next state.
func request_transition(target_state_path: NodePath, data: Variant = null) -> void:
	assert(!_block_transitions, "transitions are blocked meaning a transition was" +\
	"called in _state_exited")
	
	var target_state: State = get_node(target_state_path) as State
	assert(target_state != null, "Node @ path (%s) is missing or not of type State" \
	 % target_state_path)
	_transition_requested.emit(target_state, data)


## Called as this state is entered.[br]
## [param data] The data sent from the previous [State]
func _state_entered(data: Variant) -> void:
	pass


## Called as this state is exited.
func _state_exited() -> void:
	pass


func _to_string() -> String:
	return "State(%s)" % name
