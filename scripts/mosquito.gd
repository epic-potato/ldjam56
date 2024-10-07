class_name Mosquito

extends Firefly

@onready var audio: AudioPlayer = $player

var axe: AxeHitbox
var in_range := false


func _ready():
	pass


func _process(dt: float):
	if dead:
		timer -= dt
		if timer <= 0:
			enable()
		return

	if in_range and axe != null and axe.is_active():
		die() 
		return

	flutter(dt)


func detach() -> void:
	pass


func _on_zone_body_entered(body: Node2D):
	if !body is Frog or dead:
		return

	var frog: Frog = body as Frog
	frog.hurt((position - frog.position).normalized())



func _on_zone_area_entered(area: Area2D):
	if !area is AxeHitbox:
		return

	in_range = true
	axe = area as AxeHitbox
	if axe.is_active():
		die()


func _on_zone_area_exited(area:Area2D):
	if !area is AxeHitbox:
		return

	in_range = false


func die() -> void:
	disable()
	audio.play_sound("hit")
