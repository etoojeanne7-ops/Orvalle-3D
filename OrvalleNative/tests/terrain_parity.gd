extends SceneTree

func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		push_error("Scene missing")
		quit(1)
		return
	var world: Node3D = packed.instantiate() as Node3D
	root.add_child(world)
	await process_frame
	await process_frame
	for node_name in ["Ground", "Sun", "Player", "HUD"]:
		if world.get_node_or_null(node_name) == null:
			push_error("Required node missing: " + node_name)
			quit(1)
			return
	var tree_count := 0
	for child in world.get_children():
		if child.name.begins_with("Tree"):
			tree_count += 1
	if tree_count < 20:
		push_error("Expected generated trees; found " + str(tree_count))
		quit(1)
		return
	print("ORVALLE WORLD TEST PASS: terrain, player, HUD and trees")
	quit(0)
