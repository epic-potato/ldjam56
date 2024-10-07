class_name Frog

extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	TONGUE,
	ZIP,
	WIN,
}

enum TongueState {
	FIRE,
	ATTACHED,
	RETRACT,
	READY,
}

@export var max_tongue_length := 250
@export var gravity := 2000 # how strong is gravity
@export var coyote_time := 0.5 # seconds after leaving ground that jumping is possible

@export var jump_force := 575 # how high you jump
@export var variable_jump_div := 2 # how much releasing the jump key cuts your jump

@export var accel := 2000 # horizontal acceleration
@export var air_accel := 750 # horizontal acceleration
@export var zip_accel := 2000 # zip acceleration
@export var ground_speed := 280 # horizontal top speed (default to 6 character widths per second)
@export var air_speed := 32 * 32 # max speed the character can move in the air


@onready var sprite: AnimatedSprite2D = $sprite
@onready var axe: Sprite2D = $axe
@onready var tongue: Line2D = $Tongue
@onready var audio: AudioPlayer = $player
@onready var cam: Camera2D = $Camera2D

var zip_vel: float = 0

var coyote_time_left := coyote_time
var tongue_state := TongueState.READY

var state: State = State.IDLE

var target_found: bool = false
var target := Vector2.ZERO
var anchor: Anchor = null
var end := global_position
var ray := RayCast2D.new()

const DEATH_TIMER: float = 1
var death_timer := DEATH_TIMER
var dying := false

func _ready() -> void:
	ray.collide_with_areas = true
	ray.exclude_parent = true
	ray.hit_from_inside = true
	ray.enabled = false

	add_child(ray)


func find_target(target_pos: Vector2) -> void:
	ray.target_position = target_pos - position
	ray.collision_mask = 3
	ray.force_raycast_update()
	if !ray.is_colliding():
		return

	var collider := ray.get_collider()
	if !collider is Anchor:
		target = ray.get_collision_point()
		return

	if position.distance_to(collider.position) > max_tongue_length:
		return

	if !(collider as Anchor).hit():
		return

	anchor = collider as Anchor
	target = anchor.global_position
	target_found = true


func _input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			tongue_state = TongueState.RETRACT
			if anchor != null:
				anchor.detach()
				anchor = null
			target = position

		if event.is_pressed() and tongue_state == TongueState.READY:
			# target = position + (event.position - position).normalized() * tongue_max_length
			var mouse_pos := get_local_mouse_position()

			target = position + (mouse_pos.normalized() * max_tongue_length)
			find_target(target)
			tongue_state = TongueState.FIRE


func handle_tongue(dt: float) -> void:
	tongue.global_position = Vector2(0, 0)
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

	tongue.set_point_position(0, position + Vector2.DOWN * 8)
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

	if tongue_state == TongueState.FIRE or tongue_state == TongueState.RETRACT:
		new_state = State.TONGUE

	if tongue_state == TongueState.ATTACHED:
		new_state = State.ZIP

	state = new_state

func jump() -> void:
	velocity.y = -jump_force
	coyote_time_left = 0
	audio.play_sound("jump")

func handle_frame(dt: float) -> void:
	var run_dir = float(Input.is_action_pressed("right")) - float(Input.is_action_pressed("left"))

	if tongue_state == TongueState.ATTACHED:
		if position.distance_to(target) < 16:
			tongue_state = TongueState.READY

		zip_vel += zip_accel * dt
		velocity = (target - position).normalized() * min(zip_vel, air_speed)
		return

	zip_vel = 0
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

	if run_dir < 0:
		sprite.flip_h = true
		axe.scale.x = -1
	elif run_dir > 0:
		sprite.flip_h = false
		axe.scale.x = 1

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


func _process(dt: float) -> void:
	if state == State.WIN:
		return

	if dying:
		death_timer -= dt
		if death_timer <= 0:
			die()

	handle_frame(dt)
	handle_tongue(dt)
	handle_state()
	sprite.rotation = 0
	match state:
		State.TONGUE:
			sprite.play("tongue_launch")
			sprite.speed_scale = 0
			sprite.frame = 1
		State.ZIP:
			sprite.play("hanging_wiggle_butt")
			var angle = (target - position).angle()
			sprite.rotation = angle + (PI / 2)
		_:
			sprite.play("blink")
	move_and_slide()

	if position.y > cam.limit_bottom:
		dying = true
	else:
		dying = false
		death_timer = DEATH_TIMER


func die() -> void:
	SceneManager.restart_scene(get_tree().get_root())
