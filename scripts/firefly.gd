class_name Firefly

extends Anchor

@export var respawn_timer: float = 1.5

@onready var sprite := $sprite

var timer: float = respawn_timer
var dead: bool = false
var float_pos: Vector2 = Vector2.ZERO


func disable() -> void:
	sprite.hide()
	collision_layer = 4
	dead = true


func enable() -> void:
	sprite.show()
	collision_layer = 3
	dead = false
	timer = respawn_timer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func flutter(dt: float) -> void:
	if sprite.position.distance_to(float_pos) > 0.1:
		sprite.position = lerp(sprite.position, float_pos, dt * 3)
	else:
		float_pos = Vector2(randf() * 16 - 8, randf() * 16 - 8)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float) -> void:
	if dead:
		timer -= dt
		if timer <= 0:
			enable()
		return

	flutter(dt)


func _on_hitbox_body_entered(body:Node2D):
	if body is Frog:
		disable()


func hit() -> bool:
	return !dead


func detach():
	disable()
