class_name Mushroom

extends AnimatedSprite2D


enum MushColor {
	RANDOM,
	ORANGE,
	BLUE,
} 

@export var color: MushColor = MushColor.RANDOM

# Called when the node enters the scene tree for the first time.
func _ready():
	match color:
		MushColor.RANDOM:
			if randf() > 0.5:
				frame = 1
			else:
				frame = 0
		MushColor.ORANGE:
			frame = 0
		MushColor.BLUE:
			frame = 1


