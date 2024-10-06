extends ColorRect

@export var play_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event) -> void:
	if !event is InputEventMouseButton:
		return

	if !event.is_action("tongue"):
		return

	if !get_rect().has_point(event.position):
		return

	SceneManager.transition_to(get_tree().get_root(), play_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt: float):
	pass
