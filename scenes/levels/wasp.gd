class_name Wasp

extends Anchor

@export var frog_node: Node2D
@export var shot_cooldown: float = 2
@export var stinger_speed: float = 400
@export var stinger_scn: PackedScene = preload("res://scenes/stinger.tscn")

@onready var sprite: AnimatedSprite2D = $sprite
@onready var los: RayCast2D = $los

var frog: Frog
var can_shoot := true
var cooldown: float = 0

func _ready():
	if frog_node is Frog:
		frog = frog_node as Frog
	else:
		print("OH NOES")

func handle_shoot():
	los.target_position = frog.position - position
	if !los.is_colliding():
		return

	var collider := los.get_collider()
	if !collider is Frog:
		return

	if can_shoot:
		print("SHOOT!")
		var stinger := stinger_scn.instantiate() as Stinger
		add_child(stinger)
		stinger.set_velocity(los.target_position.normalized() * stinger_speed)
		can_shoot = false
		cooldown = shot_cooldown

func _process(dt: float) -> void:
	if !can_shoot:
		cooldown -= dt
		if cooldown <= 0:
			can_shoot = true

	if los.target_position.x > 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _physics_process(_dt: float) -> void:
	handle_shoot()
