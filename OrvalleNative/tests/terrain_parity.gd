extends SceneTree

func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		push_error("Scene missing")
		quit(1)
		return
	var world: Node3D = packed.instantiate() as Node3D
	if world == null:
		push_error("Main scene is not Node3D")
		quit(1)
		return
	root.add_child(world)
	await process_frame
	await process_frame
	for node_name in ["Ground", "Sun", "Player", "HUD"]:
		if world.get_node_or_null(node_name) == null:
			push_error("Required node missing: " + node_name)
			quit(1)
			return
	if world.get_node("Ground").get_child_count() < 2:
		push_error("Terrain mesh or collision missing")
		quit(1)
		return
	if world.get_child_count() < 30:
		push_error("Procedural environment objects missing")
		quit(1)
		return
	print("ORVALLE WORLD TEST PASS: terrain, player, HUD and procedural environment")
	quit(0)
