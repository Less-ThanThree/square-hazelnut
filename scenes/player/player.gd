extends CharacterBody3D

@onready var visuals = $Visuals
@onready var camera_mount = $CameraMount
@onready var player_animation = $Visuals/LowPolyGirlAnimation/AnimationPlayer
@onready var climbing_mount = $ClimbingMount
@onready var collision_shape = $CollisionShape3D
@onready var state_chart = $StateChart

@export var movement_speed = 5.0
@export var movement_boost = 10.0
@export var jump_velocity = 4.5
@export var horizontal_sensitivity = 0.5
@export var vertical_sensitivity = 0.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * horizontal_sensitivity))
		visuals.rotate_y(deg_to_rad(event.relative.x * horizontal_sensitivity))
		camera_mount.rotate_x(-deg_to_rad(event.relative.y * vertical_sensitivity))

func _physics_process(delta):
	var direction = _get_direction()
	var current_speed = movement_speed
	if direction:
		visuals.look_at(position + direction)
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		state_chart.send_event("move")
		_start_anim("Move", 2)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		state_chart.send_event("idle")
		_start_anim("idle", .5)
	move_and_slide()
	
	if is_on_floor():
		state_chart.send_event("grounded")
	else:
		state_chart.send_event("airborne")
	
func _on_jump_enabled_state_physics_process(delta):
	if _jumped():
		_start_anim("Jump", 1.5)				
		velocity.y = jump_velocity
		state_chart.send_event("jump")
			
func _on_airborne_state_physics_processing(delta):
	velocity.y -= gravity * delta	
	
func _get_direction():
	var input_direction = Input.get_vector("Move_left", "Move_right", "Move_forward", "Move_down")
	return (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()

func _jumped():
	return Input.is_action_pressed("Jump")

func _start_anim(name: String, scale: float):
	player_animation.set_current_animation(name)
	player_animation.speed_scale = scale




