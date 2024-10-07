extends Node2D

@export var play_scene: PackedScene

@onready var outline: Sprite2D = $outline
@onready var no_outline: Sprite2D = $no_outline
@onready var audio: AudioPlayer = $player

var hover := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("tongue") and hover:
			SceneManager.transition_to(get_tree().get_root(), play_scene)


func _on_button_mouse_exited():
	hover = false
	outline.hide()
	no_outline.show()


func _on_button_mouse_entered():
	hover = true
	outline.show()
	no_outline.hide()
	audio.play_sound("hover")

