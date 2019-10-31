extends KinematicBody

onready var collision_shape: CollisionShape = $CollisionShape
onready var gravity: float = -ProjectSettings.get("physics/3d/default_gravity")

export var max_slope_angle = 40
export var original_height = 1.8
export var original_shape_y_position = 0
export var crouch_speed = 3
export var crouch_height = 1
export var crouch_shape_y_position = -0.43
export var walk_speed = 10
export var walk_step = 3
export var stop_step = 5

export var crouch_key = KEY_CONTROL

var velocity = Vector3()
var direction = Vector3()
var is_grounded = false
var is_crouching = false
	
func _process(delta):
	process_crouch(delta)
	
func process_crouch(delta):
	var shape = collision_shape.get_shape()
	
	if is_crouching:
		collision_shape.translation.y = crouch_shape_y_position
	else:
		collision_shape.translation.y = original_shape_y_position
	
func _physics_process(delta):
	process_input(delta)
	
func _input(event):
	if event is InputEventKey:
		if event.is_echo():
			return

		if Input.is_key_pressed(crouch_key):
			if event.pressed:
				is_crouching = !is_crouching

func process_input(delta):
	HandleMovement(delta)

func HandleMovement(delta):
	direction = Vector3()
	
	var input_movement_vector = Vector2()
	
	if Input.is_key_pressed(KEY_W):
		input_movement_vector.y += 1
	if Input.is_key_pressed(KEY_S):
		input_movement_vector.y -= 1
	if Input.is_key_pressed(KEY_A):
		input_movement_vector.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_movement_vector.x += 1
		
	input_movement_vector = input_movement_vector.normalized()
	
	direction += -self.transform.basis.z * input_movement_vector.y
	direction += self.transform.basis.x * input_movement_vector.x
	
	direction.y = 0
	direction = direction.normalized()
	velocity.y += delta * gravity * 2
	
	var h_velo = velocity
	h_velo.y = 0
	
	var target_velocity = direction
	target_velocity *= walk_speed
	
	var acceleration
	
	if direction.dot(h_velo) > 0:
		acceleration = walk_step
	else:
		acceleration = stop_step
		
	h_velo = h_velo.linear_interpolate(target_velocity, acceleration * delta)
	
	velocity.x = h_velo.x
	velocity.z = h_velo.z
	velocity = move_and_slide(velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(max_slope_angle))

