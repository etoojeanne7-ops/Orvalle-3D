extends SceneTree

func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		push_error("TERRAIN PARITY FAIL: scène principale absente")
		quit(1)
		return

	var world: Node3D = packed.instantiate() as Node3D
	if world == null:
		push_error("TERRAIN PARITY FAIL: la scène n'est pas une Node3D")
		quit(1)
		return

	root.add_child(world)
	await process_frame
	await process_frame

	var required := ["Ground", "Sun", "Player", "HUD"]
	for node_name in required:
		if world.get_node_or_null(node_name) == null:
			push_error("TERRAIN PARITY FAIL: nœud requis absent: " + node_name)
			quit(1)
			return

	var ground := world.get_node("Ground") as StaticBody3D
	if ground.get_node_or_null("CollisionShape3D") == null:
		push_error("TERRAIN PARITY FAIL: collision du terrain absente")
		quit(1)
		return

	var tree_count := 0
	for child in world.get_children():
		if child is Node3D and child != world.get_node("Player") and child.name.begins_with("@Node3D"):
			tree_count += 1
	if tree_count < 20:
		push_error("TERRAIN PARITY FAIL: décor végétal insuffisant: " + str(tree_count))
		quit(1)
		return

	print("TERRAIN PARITY PASS: terrain/collision/joueur/HUD présents; décor généré: ", tree_count)
	quit(0)
