extends Area2D

var frog: Frog

func _ready():
	pass

func get_normal() -> Vector2:
	var normal = (frog.velocity * -1).normalized()
	if normal.y == 0:
		normal.y = -1
	return normal
func _process(_dt: float) -> void:
	if frog != null:
		frog.hurt(get_normal())


func _on_body_entered(body:Node2D):
	if !body is Frog:
		return
	frog = body as Frog
	frog.hurt(get_normal())

func _on_body_exited(body:Node2D):
	if body is Frog:
		frog = null
