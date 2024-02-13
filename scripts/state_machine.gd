class_name StateMachine
extends Node

@export var CURRENT_STATE: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("Содержит не совместимую ноду машины, ИДИОТ!!")
	
	CURRENT_STATE.enter()

func _process(delta):
	CURRENT_STATE.update(delta)
	Global.debug.add_debug_property("Current State", CURRENT_STATE.name)

func _physics_process(delta):
	CURRENT_STATE.physics_update(delta)

func _input(event):
	CURRENT_STATE.handle_input(event)

func on_child_transition(new_state_machine: StringName) -> void:
	var new_state = states.get(new_state_machine)
	if new_state != null:
		if new_state != CURRENT_STATE:
			CURRENT_STATE.exit()
			new_state.enter()
			CURRENT_STATE = new_state
	else:
		push_warning("Состояние не существует, ИДИОТ!!")

