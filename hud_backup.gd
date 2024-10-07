extends CanvasLayer

@export var heart_scene: PackedScene
@export var max_health: float = 3

@onready var hearts_node: Node2D = $hearts

var heart_arr: Array[AnimatedSprite2D] = []

func _ready():
	for i in range(max_health):
		var heart = heart_scene.instantiate()
		heart.position.x = (i * 16)
		if i > 0:
			heart.position.x += 2

		heart_arr.append(heart)
		hearts_node.add_child(heart)

func _on_frog_health_changed(hp: int):
	for i in range(max_health):
		heart_arr[i].frame = 0
		if i + 1 > hp:
			heart_arr[i].frame = 1
