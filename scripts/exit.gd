extends StaticBody2D


var triggered := false
var frog: Frog

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float):
	if triggered:
		frog.position = lerp(frog.position, position + Vector2.UP * 16, dt * 5)


func _on_zone_body_entered(body:Node2D):
	if body is Frog:
		frog = body as Frog
		triggered = true
		frog.state = Frog.State.WIN

