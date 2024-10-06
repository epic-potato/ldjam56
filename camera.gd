extends Camera2D


@export var target_dimensions: Vector2i = Vector2i(1920 / 2, 1080 /2) # we want 2x zoom on 1080p screens
# @onready var hud := $HUD
# @onready var fps: Label = hud.get_node("fps_label")
var elapsed := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# zoom = Vector2(1, 1) + Vector2(target_dimensions) / get_viewport_rect().size
	zoom = get_viewport_rect().size / Vector2(target_dimensions)
	print("Viewport:")
	print(get_viewport_rect().size)

	print("Target:")
	print(target_dimensions)

	print("ZOOM:")
	print(zoom)
	# hud.scale = zoom

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float) -> void:
	elapsed += dt

	if elapsed > 1.0:
		# fps.text = "FPS: %d" % Engine.get_frames_per_second()
		elapsed = 0
