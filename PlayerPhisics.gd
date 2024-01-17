extends CharacterBody3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

var target_velocity = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Храним локальное направление игрока
	var direction = Vector3.ZERO
	
	# Считаем вектр падения каждый кадр
	if not is_on_floor():
		target_velocity.y -= gravity * delta
	
	# Вектор движения игрока
	if Input.is_action_pressed("Move_right"):
		direction.x += 1
	if Input.is_action_pressed("Move_left"):
		direction.x -= 1
	if Input.is_action_pressed("Move_down"):
		direction.z += 1
	if Input.is_action_pressed("Move_forward"):
		direction.z -= 1
	
	if Input.is_action_pressed("Jump") and is_on_floor():
		target_velocity.y = JUMP_VELOCITY
	
	# Нормаль направления
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	
	target_velocity.x = direction.x * SPEED
	target_velocity.z = direction.z * SPEED
	
	velocity = target_velocity
	move_and_slide()
