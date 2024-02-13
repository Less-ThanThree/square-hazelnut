class_name PlayerWalk
extends State

func update(delta):
	owner.player_animation.set_current_animation("Move")
	
	if owner.velocity.length() == 0.0 && owner.is_on_floor():
		transition.emit("PlayerIdle")

func handle_input(event):
	if event.is_action_pressed("Run"):
		transition.emit("PlayerRun")
