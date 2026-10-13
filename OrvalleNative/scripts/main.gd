extends Node3D

const PLAYER_SPEED := 5.0
const LOOK_SENSITIVITY := 0.0025
const TERRAIN_SIZE := 120.0
const TERRAIN_RESOLUTION := 72

var player: CharacterBody3D
var camera_pivot: Node3D
var camera: Camera3D
var hud_label: Label
var pitch := -0.22
var mobile_move := Vector2.ZERO
var human_model_loaded := false

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
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.16, 0.30, 0.48)
	sky_material.sky_horizon_color = Color(0.66, 0.75, 0.82)
	sky_material.ground_bottom_color = Color(0.13, 0.17, 0.12)
	sky_material.ground_horizon_color = Color(0.48, 0.53, 0.43)
	environment.sky.sky_material = sky_material
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.78, 0.88)
	environment.ambient_light_energy = 0.8
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.ssao_enabled = true
	world_env.environment = environment
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 100.0
	add_child(sun)

	_build_terrain()
	_build_forest_and_rocks()

func _terrain_height(x: float, z: float, noise: FastNoiseLite) -> float:
	var broad := noise.get_noise_2d(x * 0.55, z * 0.55) * 2.7
	var detail := noise.get_noise_2d(x * 2.8, z * 2.8) * 0.32
	return broad + detail

func _build_terrain() -> void:
	var noise := FastNoiseLite.new()
	noise.seed = 24681
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.018
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.48

	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := TERRAIN_SIZE * 0.5
	var step := TERRAIN_SIZE / float(TERRAIN_RESOLUTION)
	for z_index in range(TERRAIN_RESOLUTION):
		for x_index in range(TERRAIN_RESOLUTION):
			var x0 := -half + float(x_index) * step
			var x1 := x0 + step
			var z0 := -half + float(z_index) * step
			var z1 := z0 + step
			var a := Vector3(x0, _terrain_height(x0, z0, noise), z0)
			var b := Vector3(x1, _terrain_height(x1, z0, noise), z0)
			var c := Vector3(x0, _terrain_height(x0, z1, noise), z1)
			var d := Vector3(x1, _terrain_height(x1, z1, noise), z1)
			_add_terrain_triangle(surface, a, c, b)
			_add_terrain_triangle(surface, b, c, d)
	surface.generate_normals()
	var terrain_mesh := surface.commit()
	var ground := StaticBody3D.new()
	ground.name = "Ground"
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "TerrainMesh"
	mesh_instance.mesh = terrain_mesh
	var terrain_material := ShaderMaterial.new()
	var terrain_shader := load("res://shaders/terrain.gdshader") as Shader
	if terrain_shader != null:
		terrain_material.shader = terrain_shader
		mesh_instance.material_override = terrain_material
	else:
		var grass := StandardMaterial3D.new()
		grass.albedo_color = Color(0.22, 0.30, 0.17)
		grass.roughness = 1.0
		grass.vertex_color_use_as_albedo = true
		mesh_instance.material_override = grass
	ground.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	collision.name = "TerrainCollision"
	collision.shape = terrain_mesh.create_trimesh_shape()
	ground.add_child(collision)
	add_child(ground)

func _add_terrain_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	for vertex in [a, b, c]:
		var noise := sin(vertex.x * 0.31) * cos(vertex.z * 0.27)
		var green := clampf(0.40 + noise * 0.08 + vertex.y * 0.012, 0.22, 0.58)
		surface.set_color(Color(0.22 + green * 0.22, green, 0.15 + green * 0.12))
		surface.add_vertex(vertex)

func _build_forest_and_rocks() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77391
	for i in range(64):
		var tree := _make_tree(rng.randf_range(0.75, 1.35))
		var angle := rng.randf_range(0.0, TAU)
		var radius := rng.randf_range(9.0, 54.0)
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		tree.position = Vector3(x, _terrain_height(x, z, _forest_noise()), z)
		tree.rotation.y = rng.randf_range(0.0, TAU)
		add_child(tree)
	for i in range(28):
		var rock := MeshInstance3D.new()
		rock.name = "Rock"
		var rock_mesh := SphereMesh.new()
		rock_mesh.radius = rng.randf_range(0.25, 0.8)
		rock_mesh.height = rock_mesh.radius * rng.randf_range(0.65, 1.25)
		rock.mesh = rock_mesh
		var stone := StandardMaterial3D.new()
		stone.albedo_color = Color(0.28, 0.30, 0.29)
		stone.roughness = 0.95
		rock.material_override = stone
		var angle := rng.randf_range(0.0, TAU)
		var radius := rng.randf_range(5.0, 55.0)
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		rock.position = Vector3(x, _terrain_height(x, z, _forest_noise()) + 0.1, z)
		rock.scale = Vector3(rng.randf_range(0.7, 1.4), 1.0, rng.randf_range(0.7, 1.4))
		add_child(rock)

func _forest_noise() -> FastNoiseLite:
	var noise := FastNoiseLite.new()
	noise.seed = 24681
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.018
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.48
	return noise

func _make_tree(scale_factor: float = 1.0) -> Node3D:
	var tree := Node3D.new()
	tree.name = "Tree"
	tree.scale = Vector3.ONE * scale_factor
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.15
	trunk_mesh.bottom_radius = 0.30
	trunk_mesh.height = 2.2
	trunk.mesh = trunk_mesh
	trunk.position.y = 1.1
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color(0.24, 0.15, 0.09)
	bark.roughness = 0.95
	trunk.material_override = bark
	tree.add_child(trunk)
	for layer in range(3):
		var crown := MeshInstance3D.new()
		var crown_mesh := SphereMesh.new()
		crown_mesh.radius = 1.0 - float(layer) * 0.13
		crown_mesh.height = 1.8
		crown.mesh = crown_mesh
		crown.position = Vector3(0, 2.15 + float(layer) * 0.62, 0)
		var leaves := StandardMaterial3D.new()
		leaves.albedo_color = Color(0.10 + float(layer) * 0.02, 0.24 + float(layer) * 0.025, 0.12)
		leaves.roughness = 0.92
		crown.material_override = leaves
		tree.add_child(crown)
	return tree

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, _terrain_height(0.0, 0.0, _forest_noise()) + 1.0, 0)
	add_child(player)
	var model_path := "res://characters/orvalle_human_base_cc0.glb"
	if ResourceLoader.exists(model_path):
		var model_resource := load(model_path)
		if model_resource is PackedScene:
			var human := (model_resource as PackedScene).instantiate()
			human.name = "HumanModel"
			human.scale = Vector3.ONE
			player.add_child(human)
			human_model_loaded = true
			_play_idle_animation(human)
			print("ORVALLE HUMAN MODEL LOADED: ", model_path)
	if not human_model_loaded:
		_add_capsule_fallback()
		push_warning("Human GLB not found. Showing technical capsule proxy; this is not the final character.")

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

func _play_idle_animation(root_node: Node) -> void:
	for child in root_node.find_children("*", "AnimationPlayer", true, false):
		var animation_player := child as AnimationPlayer
		if animation_player == null:
			continue
		var names := animation_player.get_animation_list()
		for preferred in ["Idle", "idle", "Armature|Idle", "mixamo.com"]:
			if names.has(preferred):
				animation_player.play(preferred)
				return
		if not names.is_empty():
			animation_player.play(names[0])
		return

func _add_capsule_fallback() -> void:
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.34
	capsule.height = 1.75
	var body_mesh := MeshInstance3D.new()
	body_mesh.name = "TechnicalCapsuleFallback"
	body_mesh.mesh = capsule
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.36, 0.24, 0.17)
	skin.roughness = 0.82
	capsule.material = skin
	body_mesh.position.y = 0.88
	player.add_child(body_mesh)

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
	hint.text = "Terrain procédural — personnage sous licence ouverte"
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
