class_name Player
extends Entity

@export_group("Movement")
@export var acceleration: float = 1.25
@export var drag: float = 500.0
@export var max_movement_speed: float = 5.5
@export var run_speed_multiplier: float = 1.4
@export var falling_acceleration: float = 1.2
@export var max_falling_speed: float = 3.0

@export_group("Camera")
@export var mouse_sensitivity: float = 0.002
@export var min_pitch: float = -80.0
@export var max_pitch: float = 80.0

@export_group("Head Bobble")
@export var bob_frequency: float = 5.0
@export var bob_vertical_amplitude: float = 0.08
@export var bob_horizontal_amplitude: float = 0.05
@export var bob_smoothing: float = 8.0

@export_group("Testing")
@export_file("*.tscn") var combat_scene_path: String

var gravity_acceleration_factor: float = 0.0
var input_vector: Vector2
var gravity_factor: Vector3
var in_ui_idle_state: bool = true
var is_running: bool = false
var camera_base_position: Vector3
var bob_time: float = 0.0
var bob_fade: float = 0.0
var current_dialogue_actionable: DialogueActionable3D

@onready var player_camera: Camera3D = $PlayerCamera


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PlayerUI.ui_changed.connect(on_ui_changed)
	current_health = max_health
	camera_base_position = player_camera.position


func _process(delta: float) -> void:
	update_head_bobble(delta)


func _physics_process(delta: float) -> void:
	get_input(delta)
	move_and_slide()


func _input(event: InputEvent) -> void:
	if not in_ui_idle_state:
		return
	if event.is_action_pressed("CombatTest"):
		SceneTransitionManager.start_combat(combat_scene_path)
	
	elif event.is_action_pressed("UICancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	elif event.is_action_pressed("Interact"):
		if current_dialogue_actionable:
			in_ui_idle_state = false
			PlayerUI.on_child_transitioned(PlayerUI.current_state, "DialogueUIState")
			current_dialogue_actionable.action()
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		player_camera.rotate_x(-event.relative.y * mouse_sensitivity)
		player_camera.rotation.x = clamp(
			player_camera.rotation.x,
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch),
		)


func get_input(delta: float) -> void:
	input_vector = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	is_running = Input.is_action_pressed("Run")
	var current_max_speed := max_movement_speed * (run_speed_multiplier if is_running else 1.0)

	var forward := -global_basis.z
	var right := global_basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()
	var desired_input_direction := forward * -input_vector.y + right * input_vector.x

	if input_vector.length() > 0:
		velocity.x = move_toward(
			velocity.x,
			desired_input_direction.x * current_max_speed,
			acceleration,
		)
		velocity.z = move_toward(
			velocity.z,
			desired_input_direction.z * current_max_speed,
			acceleration,
		)
	else:
		velocity.x = move_toward(velocity.x, 0, drag)
		velocity.z = move_toward(velocity.z, 0, drag)
	if not is_on_floor():
		gravity_acceleration_factor = clampf(
			gravity_acceleration_factor + delta * falling_acceleration,
			0,
			1,
		)
		if velocity.y <= 0:
			gravity_factor = get_gravity()
		else:
			gravity_factor = get_gravity() * 0.5
		velocity.y += gravity_factor.clamp(
			-Vector3(0, 1, 0).normalized() * max_falling_speed,
			Vector3(0, 1, 0).normalized() * max_falling_speed,
		).y

	elif is_on_floor():
		gravity_acceleration_factor = 0.0


func update_head_bobble(delta: float) -> void:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var is_moving := horizontal_speed > 0.2 and is_on_floor()

	var target_fade: float
	if is_moving:
		target_fade = 1.0
	else:
		target_fade = 0.0

	bob_fade = move_toward(bob_fade, target_fade, bob_smoothing * delta)

	if is_moving:
		var speed_ratio := horizontal_speed / max_movement_speed
		bob_time += delta * bob_frequency * speed_ratio
		bob_time = fmod(bob_time, TAU)

	var vertical_offset := sin(bob_time * 2.0) * bob_vertical_amplitude * bob_fade
	var horizontal_offset := sin(bob_time) * bob_horizontal_amplitude * bob_fade

	player_camera.position = camera_base_position + Vector3(horizontal_offset, vertical_offset, 0.0)


func take_damage(damage_amount: int) -> void:
	current_health = max(0, current_health - damage_amount)

	var text_to_print: String = "{0} took {1} damage".format([entity_name, damage_amount])
	print(text_to_print)

	var particle_instance := BLOOD_PARTICLES.instantiate()
	particle_instance.position = player_camera.get_child(0).global_position
	get_tree().root.add_child(particle_instance)


func receive_block(block_amount: int) -> void:
	current_block += block_amount

	var text_to_print: String = "{0} received {1} block".format([entity_name, block_amount])
	print(text_to_print)

	var particle_instance := BLOCK_PARTICLES.instantiate()
	particle_instance.position = player_camera.get_child(0).global_position
	get_tree().root.add_child(particle_instance)


func on_ui_changed(new_ui_state: State) -> void:
	if new_ui_state.name == "IdleUIState":
		in_ui_idle_state = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		in_ui_idle_state = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_detection_area_entered(area: Area3D) -> void:
	if area is DialogueActionable3D:
		current_dialogue_actionable = area


func _on_detection_area_exited(area: Area3D) -> void:
	if area == current_dialogue_actionable:
		current_dialogue_actionable = null
