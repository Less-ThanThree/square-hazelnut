extends CharacterBody3D

@onready var visuals = $Visuals
@onready var camera_mount = $CameraMount
@onready var player_animation = $Visuals/LowPolyGirlAnimation/AnimationPlayer
@onready var climbing_mount = $ClimbingMount
@onready var collision_shape = $CollisionShape3D

@export var MovementSpeed = 5.0
@export var ClimbingSpeed = 2.0
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
		camera_mount.rotate_x(-deg_to_rad(event.relative.y * VerticalSensitivity))

func _physics_process(delta):
	# Получаем вектор движения игрока
	var input_direction = Input.get_vector("Move_left", "Move_right", "Move_forward", "Move_down")
	var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	var current_speed = MovementSpeed
	
	# Считаем вектр падения каждый кадр
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = JumpVelocity
		player_animation.set_current_animation("Jump")
		player_animation.speed_scale = 1.5
	if (Input.is_action_pressed("Move_forward") and is_on_floor() and !Input.is_action_pressed("Run") and !Input.is_action_pressed("Jump")) or (Input.is_action_pressed("Move_down") and is_on_floor() and !Input.is_action_pressed("Run") and !Input.is_action_pressed("Jump")) or (Input.is_action_pressed("Move_left") and is_on_floor() and !Input.is_action_pressed("Run") and !Input.is_action_pressed("Jump")) or (Input.is_action_pressed("Move_right") and is_on_floor() and !Input.is_action_pressed("Run") and !Input.is_action_pressed("Jump")):
		player_animation.set_current_animation("Move")
		player_animation.speed_scale = 2
		current_speed = MovementSpeed
	if (Input.is_action_pressed("Move_forward") and Input.is_action_pressed("Run") and is_on_floor()) or (Input.is_action_pressed("Move_left") and Input.is_action_pressed("Run") and is_on_floor()) or (Input.is_action_pressed("Move_right") and Input.is_action_pressed("Run") and is_on_floor()) or (Input.is_action_pressed("Move_down") and Input.is_action_pressed("Run") and is_on_floor()):
		current_speed = MovementBoost
		player_animation.set_current_animation("Run")
		player_animation.speed_scale = 3
	
	if input_direction == Vector2(0, 0) and velocity.y == 0:
		player_animation.set_current_animation("idle")
		player_animation.speed_scale = 0.5
		
	if direction:
		visuals.look_at(position + direction)
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		if(climbing()):
			# Место где персонаж поднимается
			velocity.y = 1 * ClimbingSpeed
			player_animation.set_current_animation("Climb")
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
	move_and_slide()

func raycast(from: Vector3, to: Vector3, layer: int):
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to, layer, [self])
	query.collide_with_areas = true
	return space.intersect_ray(query)
	
var _previous_climbing_place: Dictionary

func climbing():
	var climbing_transform_origin = climbing_mount.global_transform.origin
	var climbing_global = climbing_mount.to_global(Vector3.FORWARD)
	var start_hit = raycast(climbing_transform_origin, climbing_global, 2)
	if start_hit:
		var from = start_hit.position + self.to_global(Vector3.FORWARD) * collision_shape.shape.radius + (Vector3.UP * collision_shape.shape.height)
		var to = Vector3.DOWN * (collision_shape.shape.height)
		var place_to_land = raycast(from,to, 2)
		if !place_to_land && _previous_climbing_place:
			position = _previous_climbing_place.position
			_previous_climbing_place = {}
			# Место, где происходит окончательное поднятие на поверхность (в верхней точке)
		else:
			_previous_climbing_place = place_to_land
		return true
	else:
		return false
