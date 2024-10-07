class_name SceneManager

static var current_scene: PackedScene

static func transition_to(root: Node, scene: PackedScene) -> void:
	current_scene = scene

	var real_root = root.get_node("root")
	var level := real_root.get_node_or_null("level")
	if level == null:
		# this happens when testing a level without starting at the menu
		root.get_tree().change_scene_to_packed(scene)
		return
	real_root.remove_child(level)
	level.queue_free()
	var new_level := scene.instantiate()
	new_level.name = "level"

	real_root.add_child(new_level)

static func restart_scene(root: Node) -> void:
	transition_to(root, current_scene)
