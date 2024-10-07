class_name Wasp

extends Area2D

enum State {
	IDLE,
	FIRE,
}

@export var frog_node: Node2D
@export var shot_cooldown: float = 2
@export var stinger_speed: float = 400
@export var stinger_scn: PackedScene = preload("res://scenes/stinger.tscn")

@onready var sprite: AnimatedSprite2D = $sprite
@onready var los: RayCast2D = $los
@onready var audio: AudioPlayer = $player

var frog: Frog
var can_shoot := false
var cooldown: float = shot_cooldown * 1.5
var state := State.IDLE

var axe: AxeHitbox
var in_range := false
var dead := false


func _ready():
	if frog_node is Frog:
		frog = frog_node as Frog
	else:
		print("OH NOES")


func handle_state() -> void:
	match state:
		State.IDLE:
			sprite.play("idle")
		State.FIRE:
			sprite.play("attack")

func shoot() -> void:
	var stinger := stinger_scn.instantiate() as Stinger
	los.add_child(stinger)

	stinger.set_velocity(los.target_position.normalized() * stinger_speed)
	can_shoot = false
	cooldown = shot_cooldown

func handle_shoot():
	los.target_position = (frog.position + Vector2.UP * 4) - position
	if !los.is_colliding():
		return

	var collider := los.get_collider()
	if !collider is Frog:
		return

	if can_shoot:
		state = State.FIRE
		sprite.play("attack")

	if State.FIRE and sprite.frame >= 3 and can_shoot:
		shoot()


func _physics_process(dt: float) -> void:
	if dead:
		return

	if in_range and axe != null and axe.is_active():
		die() 
		return

	if !can_shoot:
		cooldown -= dt
		if cooldown <= 0:
			can_shoot = true

	if los.target_position.x > 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

	handle_shoot()
	handle_state()


func _on_sprite_animation_looped():
	if state == State.FIRE:
		state = State.IDLE
		sprite.play("idle")

func die():
	sprite.hide()
	collision_layer = 4
	dead = true
	audio.play_sound("die")

func _on_area_exited(area: Area2D):
	if !area is AxeHitbox:
		return

	in_range = false

func _on_area_entered(area: Area2D):
	if area is AxeHitbox:
		in_range = true
		axe = area as AxeHitbox
		if axe.is_active():
			die()

func _on_body_entered(body: Node2D):
	if body is Frog:
		var f: Frog = body as Frog
		f.hurt((position - f.position).normalized())


