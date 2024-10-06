extends Camera2D


@export var target_dimensions: Vector2i = Vector2i(1920 / 2, 1080 /2)  # we want 2x zoom on 1080p screens

# @onready var hud := $HUD
# @onready var fps: Label = hud.get_node("fps_label")
var elapsed := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# compute camera limits based on the tiles
	var tilemap: TileMapLayer = get_node("/root/root/tilemap")

	if tilemap != null:
		var tile_rect = tilemap.get_used_rect()
		limit_left = 0
		limit_top = 0
		limit_right = max(target_dimensions.x, (tile_rect.size.x * 16) - 8)
		limit_bottom = max(target_dimensions.y, (tile_rect.size.y * 16)- 8)

	zoom = get_viewport_rect().size / Vector2(target_dimensions)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float) -> void:
	elapsed += dt

	if elapsed > 1.0:
		# fps.text = "FPS: %d" % Engine.get_frames_per_second()
		elapsed = 0
