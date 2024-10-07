class_name Stinger

extends Area2D


@onready var sprite: AnimatedSprite2D = $sprite
var velocity: Vector2 = Vector2.LEFT


func set_velocity(vel: Vector2) -> void:
	velocity = vel
	sprite.rotation = velocity.angle()


func _on_body_entered(body: Node2D):
	if !body is Frog:
		queue_free()
		return

	(body as Frog).hurt(velocity.normalized())
	queue_free()

func _process(dt: float) -> void:
	self.position += velocity * dt
