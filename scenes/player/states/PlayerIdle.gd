class_name PlayerIdle
extends State

func update(delta):
	owner.player_animation.set_current_animation("idle")
	
	if owner.velocity.length() > 0.0 && owner.is_on_floor():
		transition.emit("PlayerWalk")
