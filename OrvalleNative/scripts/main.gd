extends Node3D

const PLAYER_SPEED := 5.0
const LOOK_SENSITIVITY := 0.0025

var player: CharacterBody3D
var camera_pivot: Node3D
var camera: Camera3D
var hud_label: Label
var pitch := -0.22
var mobile_move := Vector2.ZERO

func _ready() -> void:
	_build_world()
	_build_player()
	_build_hud()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if not OS.has_feature("mobile") else Input.MOUSE_MODE_VISIBLE

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.sky.sky_material = ProceduralSkyMaterial.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.78, 0.88)
	environment.ambient_light_energy = 0.8
	world_env.environment = environment
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)

	var ground := StaticBody3D.new()
	ground.name = "Ground"
	var ground_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(160, 160)
	ground_mesh.mesh = plane
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color(0.20, 0.31, 0.20)
	grass.roughness = 1.0
	plane.material = grass
	ground.add_child(ground_mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(160, 0.2, 160)
	collision.shape = shape
	collision.position.y = -0.1
	ground.add_child(collision)
	add_child(ground)

	# Low-poly landscape props are intentionally placeholders until final art assets exist.
	for i in range(32):
		var tree := _make_tree()
		var angle := float(i) * TAU / 32.0
		tree.position = Vector3(cos(angle) * (12.0 + float(i % 4) * 3.0), 0, sin(angle) * (12.0 + float(i % 4) * 3.0))
		add_child(tree)

func _make_tree() -> Node3D:
	var tree := Node3D.new()
	tree.name = "Tree"
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.18
	trunk_mesh.bottom_radius = 0.28
	trunk_mesh.height = 1.8
	trunk.mesh = trunk_mesh
	trunk.position.y = 0.9
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color(0.25, 0.16, 0.10)
	trunk_mesh.material = bark
	tree.add_child(trunk)
	var crown := MeshInstance3D.new()
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = 1.0
	crown_mesh.height = 2.0
	crown.mesh = crown_mesh
	crown.position.y = 2.2
	var leaves := StandardMaterial3D.new()
	leaves.albedo_color = Color(0.12, 0.28, 0.16)
	crown_mesh.material = leaves
	tree.add_child(crown)
	return tree

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, 1, 0)
	add_child(player)
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.34
	capsule.height = 1.75
	var body_mesh := MeshInstance3D.new()
	body_mesh.mesh = capsule
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.36, 0.24, 0.17)
	skin.roughness = 0.82
	capsule.material = skin
	body_mesh.position.y = 0.88
	player.add_child(body_mesh)
	var collider := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.34
	capsule_shape.height = 1.75
	collider.shape = capsule_shape
	collider.position.y = 0.88
	player.add_child(collider)

	camera_pivot = Node3D.new()
	camera_pivot.position.y = 1.5
	player.add_child(camera_pivot)
	camera = Camera3D.new()
	camera.position = Vector3(0, 1.0, 5.5)
	camera.current = true
	camera_pivot.add_child(camera)
	camera.look_at(player.global_position + Vector3.UP * 1.0)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size = Vector2(310, 82)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var title := Label.new()
	title.text = "ORVALLE  •  EXPLORATION"
	title.add_theme_font_size_override("font_size", 18)
	column.add_child(title)
	hud_label = Label.new()
	hud_label.text = "WASD / flèches : déplacement  •  souris : caméra"
	column.add_child(hud_label)
	var hint := Label.new()
	hint.text = "Prototype natif — personnages finaux en production"
	hint.add_theme_font_size_override("font_size", 12)
	column.add_child(hint)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.rotate_y(-event.relative.x * LOOK_SENSITIVITY)
		pitch = clampf(pitch - event.relative.y * LOOK_SENSITIVITY, -1.0, 0.55)
		camera_pivot.rotation.x = pitch
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if mobile_move.length() > 0.1:
		input_vector = mobile_move
	var direction := (player.transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	if direction.length() > 0.0:
		player.velocity.x = direction.x * PLAYER_SPEED
		player.velocity.z = direction.z * PLAYER_SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, PLAYER_SPEED * 4.0 * delta)
		player.velocity.z = move_toward(player.velocity.z, 0.0, PLAYER_SPEED * 4.0 * delta)
	if not player.is_on_floor():
		player.velocity.y -= 20.0 * delta
	else:
		player.velocity.y = -0.1
	player.move_and_slide()
