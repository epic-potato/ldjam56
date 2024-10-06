class_name Firefly

extends Anchor

@export var respawn_timer: float = 3
@onready var sprite := $Sprite2D

var timer: float = respawn_timer
var dead: bool = false


func disable() -> void:
	sprite.hide()
	collision_layer = 1
	dead = true


func enable() -> void:
	sprite.show()
	collision_layer = 3
	dead = false
	timer = respawn_timer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float) -> void:
	if !dead:
		return

	timer -= dt
	if timer <= 0:
		enable()


func _on_hitbox_body_entered(body:Node2D):
	if body is Frog:
		disable()


func detach():
	disable()
