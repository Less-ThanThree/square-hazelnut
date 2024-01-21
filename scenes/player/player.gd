extends CharacterBody3D

@onready var visuals = $Visuals
@onready var cameraMount = $CameraMount
@onready var playerAnimation = $Visuals/LowPolyGirlAnimation/AnimationPlayer

@export var MovementSpeed = 5.0
@export var MovementBoost = 10.0
@export var JumpVelocity = 4.5
@export var HorizontalSensitivity = 0.5
@export var VerticalSensitivity = 0.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * HorizontalSensitivity))
		visuals.rotate_y(deg_to_rad(event.relative.x * HorizontalSensitivity))
		cameraMount.rotate_x(-deg_to_rad(event.relative.y * VerticalSensitivity))

func _physics_process(delta):
	
	# Получаем вектор движения игрока
	var inputDirection = Input.get_vector("Move_left", "Move_right", "Move_forward", "Move_down")
	var direction = (transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized()
	var currentSpeed = MovementSpeed
	
	# Считаем вектр падения каждый кадр
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = JumpVelocity
		playerAnimation.set_current_animation("Jump")
		playerAnimation.speed_scale = 1.5
	if (Input.is_action_pressed("Move_forward") and is_on_floor() and !Input.is_action_pressed("Run") and !Input.is_action_pressed("Jump")) or (Input.is_action_pressed("Move_down") and is_on_floor() and !Input.is_action_pressed("Run") and !Input.is_action_pressed("Jump")) or (Input.is_action_pressed("Move_left") and is_on_floor() and !Input.is_action_pressed("Run") and !Input.is_action_pressed("Jump")) or (Input.is_action_pressed("Move_right") and is_on_floor() and !Input.is_action_pressed("Run") and !Input.is_action_pressed("Jump")):
		playerAnimation.set_current_animation("Move")
		playerAnimation.speed_scale = 2
		currentSpeed = MovementSpeed
	if (Input.is_action_pressed("Move_forward") and Input.is_action_pressed("Run") and is_on_floor()) or (Input.is_action_pressed("Move_left") and Input.is_action_pressed("Run") and is_on_floor()) or (Input.is_action_pressed("Move_right") and Input.is_action_pressed("Run") and is_on_floor()) or (Input.is_action_pressed("Move_down") and Input.is_action_pressed("Run") and is_on_floor()):
		currentSpeed = MovementBoost
		playerAnimation.set_current_animation("Run")
		playerAnimation.speed_scale = 3
	
	if inputDirection == Vector2(0, 0) and velocity.y == 0:
		playerAnimation.set_current_animation("idle")
		playerAnimation.speed_scale = 0.5
	
	if direction:
		visuals.look_at(position + direction)
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)
	move_and_slide()
