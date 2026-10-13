extends SceneTree

func _initialize() -> void:
	var scene := load("res://scenes/main.tscn")
	if scene == null:
		push_error("ÉCHEC: scène principale introuvable")
		quit(1)
		return
	var instance := scene.instantiate()
	if instance == null:
		push_error("ÉCHEC: instanciation de la scène impossible")
		quit(1)
		return
	root.add_child(instance)
	await process_frame
	await process_frame
	if instance.get_node_or_null("Player") == null:
		push_error("ÉCHEC: joueur non initialisé")
		quit(1)
		return
	if instance.get_node_or_null("HUD") == null:
		push_error("ÉCHEC: HUD non initialisé")
		quit(1)
		return
	print("ORVALLE SMOKE TEST PASS: scène chargée, joueur et HUD présents")
	quit(0)
