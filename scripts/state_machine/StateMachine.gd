# Generic state machine. Initializes states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the active state.
class_name StateMachine
extends Node

# Emitted when transitioning to a new state.
signal transitioned(state_name)

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var initial_state := NodePath()

# The current active state. At the start of the game, we get the `initial_state`.
@onready var current_state: State = get_node(initial_state)
var previous_state: State

@export var debug_current_state: TextEdit
@export var debug_previous_state: TextEdit
@export var debug_transitions: VBoxContainer


func _ready() -> void:
	#await (owner, "ready")
	#yield(owner, "ready")
	# The state machine assigns itself to the State objects' state_machine property.
	if !current_state:
		push_error("Initial state not defined")
	else:
		if len(current_state.state_transitions) == 0:
			push_warning("No upward state transitions")

	for child in get_children():
		child.state_machine = self

	_update_debug()
		
	current_state.enter()


# The state machine subscribes to node callbacks and delegates them to the state objects.
func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)


func _process(delta: float) -> void:
	current_state.update(delta)


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter() function.
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	# Safety check, you could use an assert() here to report an error if the state name is incorrect.
	# We don't use an assert here to help with code reuse. If you reuse a state in different state machines
	# but you don't want them all, they won't be able to transition to states that aren't in the scene tree.
	if not has_node(target_state_name):
		return

	previous_state=current_state
	current_state.exit()
	
	current_state = get_node(target_state_name)
	_update_debug()
	current_state.enter(msg)
	emit_signal("transitioned", current_state.name)

func _update_debug() -> void:
	if debug_current_state:
		debug_current_state.text = "Current State: {state}".format({"state": current_state.state_name})
	
	if debug_previous_state:
		if previous_state:
			debug_previous_state.text = "Previous State: {state}".format({"state": previous_state.state_name})
	
	var debug_transitions_children = debug_transitions.get_children()
	for children in debug_transitions_children:
		children.queue_free()
	
	for transition in current_state.state_transitions:
		var transition_button = Button.new()
		transition_button.name = "{name}Button".format({"name": transition.state_name})
		transition_button.text = transition.state_name
		transition_button.size_flags_horizontal = 3
		transition_button.size_flags_vertical = 3
		transition_button.connect("pressed", transition_to.bind(transition.state_name, {}))
		debug_transitions.add_child(transition_button)


func _on_button_pressed():
	transition_to(previous_state.state_name, {})
