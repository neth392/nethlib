## A simple state machine implementation that manages [State]s & transitions between.[br]
## All [State]s transitioned to must be a child of this instance.
@tool
class_name StateMachine extends Node

## The default [State] to be loaded when this [StateMachine] is active.
@export var default_state: Node:
	set(value):
		default_state = value
		update_configuration_warnings()

var _current_state: State


func _ready() -> void:
	for child: Node in get_children():
		if child != default_state:
			_toggle_node_processing(child, false)
	
	# In editor, do not process and return so we don't transition to default state
	if Engine.is_editor_hint():
		_toggle_node_processing(self, false)
		return
	
	# Transition to the default state if one is set
	if default_state != null:
		assert(get_children().has(default_state), "default_state (%s) not a child " +\
		"of this StateMachine" % default_state.get_path())
		transition_to(default_state)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	
	if default_state != null && !get_children().has(default_state):
		warnings.append("default_state is not a child of this StateMachine")
	
	for child: Node in get_children():
		if !(child is State):
			push_warning("Child %s is not of type State" % child.name)
	
	return warnings


## Returns the current [State], or null if there is no current state.
func get_current_state() -> State:
	return _current_state


## Exits the current [State] (if one is active) and does not transition to
## a new state, leaving this state machine inactive.
func deactivate() -> void:
	if _current_state != null:
		_disable_current_state()


## Manually transition to the [param target_state]. [param data] is sent
## to the target state's [method State._state_entered] function.
func transition_to(target_state: State, data: Variant = null) -> void:
	assert(target_state != null, "target_state is null")
	assert(get_children().has(target_state), "target_state (%s) not a child of " +\
	"this StateMachine" % target_state.get_path())
	
	if _current_state != null:
		_disable_current_state()
	
	_set_current_state(target_state, data)


func _toggle_node_processing(node: Node, active: bool) -> void:
	node.set_process(active)
	node.set_physics_process(active)
	node.set_process_input(active)
	node.set_process_unhandled_input(active)


func _set_current_state(state: State, data: Variant) -> void:
	assert(state != null, "state is null")
	_current_state = state
	state._transition_requested.connect(_on_state_transition_requested)
	state._state_entered(data)
	# Ensure the current state is still this state in the case the state is 
	# immediately exited upon entering
	if _current_state == state:
		_toggle_node_processing(state, true)


func _disable_current_state() -> void:
	assert(_current_state != null, "state is null")
	
	_current_state._transition_requested.disconnect(_on_state_transition_requested)
	
	# Stop processing before _state_exited
	_toggle_node_processing(_current_state, false)
	
	# Cache the current state to later ensure it doesn't transition in _state_exited
	var _state: State = _current_state
	
	# Block transitions in _state_exited
	_current_state._block_transitions = true
	_current_state._state_exited()
	# Unblock transitions
	_current_state._block_transitions = false
	
	# Ensure state didn't transition in _state_exited
	assert(_current_state == _state, "_state_exited of State (%s) transitioned " +\
	"to a new state" % _state.get_path())
	
	_current_state = null


func _on_state_transition_requested(target_state: State, data: Variant) -> void:
	transition_to(target_state, data)
