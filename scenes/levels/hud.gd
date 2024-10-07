extends CanvasLayer

@export var heart_scn: PackedScene = preload("res://scenes/heart.tscn")

var health := 3
var hearts: Array[AnimatedSprite2D] = []

func _ready():
	for i in range(health):
		var heart = heart_scn.initialize()
		hearts.append()

func _on_frog_health_changed(health: int):
	health = health

