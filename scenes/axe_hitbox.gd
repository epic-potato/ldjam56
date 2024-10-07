class_name AxeHitbox

extends Area2D

@export var active_frames := 5
var active_time: float = 0


func is_active() -> bool:
	return active_time > 0


func activate() -> void:
	active_time = active_frames


func _ready():
	pass


func _process(dt: float):
	if active_time > 0:
		active_time -= dt * 60
	else:
		active_time = 0
