extends CharacterBody3D

@onready var visuals = $Visuals
@onready var cameraMount = $CameraMount

@export var MovementSpeed = 5.0
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
	# Считаем вектр падения каждый кадр
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = JumpVelocity
	
	# Получаем вектор движения игрока
	var inputDirection = Input.get_vector("Move_left", "Move_right", "Move_forward", "Move_down")
	var direction = (transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized()
	
	if direction:
		visuals.look_at(position + direction)
		velocity.x = direction.x * MovementSpeed
		velocity.z = direction.z * MovementSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, MovementSpeed)
		velocity.z = move_toward(velocity.z, 0, MovementSpeed)
	move_and_slide()
