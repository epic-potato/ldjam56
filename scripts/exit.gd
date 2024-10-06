extends StaticBody2D

@export var next_level: PackedScene

@onready var player: AudioPlayer = $player

var triggered := false
var frog: Frog
var timer: float = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float):
	if triggered:
		frog.position = lerp(frog.position, position + Vector2.UP * 16, dt * 5)
		timer -= dt

		if timer <= 0:
			SceneManager.transition_to(get_tree().get_root(), next_level)


func _on_zone_body_entered(body:Node2D):
	if body is Frog:
		frog = body as Frog
		triggered = true
		frog.state = Frog.State.WIN
		player.play_sound("win")

