class_name Frog

extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	TONGUE,
}

enum TongueState {
	FIRE,
	ATTACHED,
	RETRACT,
	READY,
}

@onready var sprite: Sprite2D = $Sprite2D

@export var tongue: Line2D
@export var gravity := 2000 # how strong is gravity
@export var coyote_time := 0.5 # seconds after leaving ground that jumping is possible

@export var jump_force := 575 # how high you jump
@export var variable_jump_div := 2 # how much releasing the jump key cuts your jump

@export var accel := 2000 # horizontal acceleration
@export var air_accel := 750 # horizontal acceleration
@export var ground_speed := 320 # horizontal top speed (default to 6 character widths per second)
@export var air_speed := 32 * 32 # max speed the character can move in the air

var coyote_time_left := coyote_time
var tongue_state := TongueState.READY

var state: State = State.IDLE

var target_found: bool = false
var target := Vector2.ZERO
var end := global_position
var ray := RayCast2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ray.collide_with_areas = true
	ray.exclude_parent = true
	ray.hit_from_inside = true
	ray.enabled = false

	add_child(ray)


func find_target(target_pos: Vector2) -> void:
	ray.target_position = target_pos - position
	ray.collision_mask = 2
	ray.force_raycast_update()
	if ray.is_colliding():
		var collider := ray.get_collider()
		if collider is Anchor:
			var anchor := collider as Anchor
			anchor.hit()
			target = anchor.global_position
			target_found = true


func _input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			tongue_state = TongueState.RETRACT
			target = position

		if event.is_pressed() and tongue_state == TongueState.READY:
			target = event.position
			find_target(event.position)
			tongue_state = TongueState.FIRE


func handle_tongue(dt: float) -> void:
	var middle := position
	match tongue_state:
		TongueState.READY:
			end = position
		TongueState.FIRE:
			end = lerp(end, target, dt * 40)
			middle = lerp(position, end, 0.5)
			if end.distance_to(target) < 16:
				if target_found:
					tongue_state = TongueState.ATTACHED
				else:
					tongue_state = TongueState.RETRACT
		TongueState.ATTACHED:
			end = target
			middle = lerp(position, end, 0.5)
		TongueState.RETRACT:
			target_found = false
			end = lerp(end, position, dt * 20)
			if end.distance_to(position) < 16:
				tongue_state = TongueState.READY
			middle = lerp(position, end, 0.5)

	tongue.set_point_position(0, position)
	tongue.set_point_position(1, middle)
	tongue.set_point_position(2, end)


func handle_state():
	var new_state = State.IDLE
	if abs(velocity.x) > 0.01:
		new_state = State.RUN

	if !is_on_floor():
		if velocity.y <= 0:
			new_state = State.JUMP
		else:
			new_state = State.FALL

	state = new_state

func jump() -> void:
	velocity.y = -jump_force
	coyote_time_left = 0

func handle_frame(dt: float) -> void:
	var run_dir = float(Input.is_action_pressed("right")) - float(Input.is_action_pressed("left"))

	if tongue_state == TongueState.ATTACHED:
		if position.distance_to(target) < 16:
			tongue_state = TongueState.READY

		velocity = (target - position).normalized() * air_speed
		return

	var acc = accel
	var friction := false
	if is_on_floor():
		friction = true
		coyote_time_left = coyote_time
		if Input.is_action_just_pressed("jump"):
			jump()
	else:
		acc = air_accel
		if coyote_time_left > 0:
			coyote_time_left -= dt
			if Input.is_action_just_pressed("jump"):
				jump()

		# variable height jumps
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y /= variable_jump_div

	velocity.y += gravity * dt
	if velocity.y > air_speed:
		velocity.y = air_speed

	var abs_velx: float = abs(velocity.x)
	if abs_velx < 20 and run_dir == 0:
		velocity.x = 0
		abs_velx = 0

	if friction:
		# moving in the opposite direction should cause "more" friction
		if run_dir == -sign(velocity.x):
			acc *= 1.5
		# no movement should cause you to slow to a stop
		elif run_dir == 0 and abs_velx > 0:
			run_dir = -sign(velocity.x)

	var new_vel: float = velocity.x + (run_dir * acc * dt)
	# allow deceleration, but not acceleration when moving faster than ground speed
	if abs_velx > ground_speed:
		velocity.x = clampf(new_vel, -abs_velx, abs_velx)
	else:
		velocity.x = clampf(new_vel, -ground_speed, ground_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float) -> void:
	handle_frame(dt)
	handle_tongue(dt)
	handle_state()
	move_and_slide()
