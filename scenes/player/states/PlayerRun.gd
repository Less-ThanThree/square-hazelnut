class_name PlayerRun
extends State

func update(delta):
	owner.player_animation.set_current_animation("Run")
	
	if owner.velocity.length() == 0.0 && owner.is_on_floor():
		transition.emit("PlayerWalk")

func handle_input(event):
	if event.is_action_released("Run"):
		transition.emit("PlayerWalk")
