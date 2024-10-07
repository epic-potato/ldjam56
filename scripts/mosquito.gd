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


func _on_zone_body_entered(body: Node2D):
	if !body is Frog or dead:
		return

	var frog: Frog = body as Frog
	frog.hurt((position - frog.position).normalized())



func _on_zone_area_entered(area: Area2D):
	if !area is AxeHitbox:
		return
	
	print("HIT MOSQUITO!")
	var axe := area as AxeHitbox
	if axe.is_active():
		disable()
