class_name Mosquito

extends Firefly


func _ready():
	pass


func _process(dt: float):
	if dead:
		timer -= dt
		if timer <= 0:
			enable()
		return

	flutter(dt)


func detach() -> void:
	pass
