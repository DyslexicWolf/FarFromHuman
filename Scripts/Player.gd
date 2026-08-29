class_name Player
extends Entity

@export_group("Movement")
@export var acceleration: float = 1.25
@export var drag: float = 500.0
@export var max_movement_speed: float = 5.5
@export var run_speed_multiplier: float = 1.4
@export var falling_acceleration: float = 1.2
@export var max_falling_speed: float = 3.0
var gravity_acceleration_factor: float = 0.0
@export_group("Camera")
@export var mouse_sensitivity: float = 0.002
@export var min_pitch: float = -80.0
@export var max_pitch: float = 80.0

@export_group("Head Bobble")
@export var bob_frequency: float = 5.0
@export var bob_vertical_amplitude: float = 0.08
@export var bob_horizontal_amplitude: float = 0.05
@export var bob_smoothing: float = 8.0

var input_vector: Vector2
var gravity_factor: Vector3

var in_ui_idle_state: bool = true
var is_running: bool = false
var camera_base_position: Vector3
var bob_time: float = 0.0
var bob_fade: float = 0.0

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
	if event.is_action_pressed("CombatTest"):
		get_tree().change_scene_to_file("res://Scenes/Combat.tscn")
	elif event.is_action_pressed("UICancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if not in_ui_idle_state:
		return
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
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
			gravity_factor = get_gravity() #* 0.1 * dress_slowfall_multiplier
		else:
			gravity_factor = get_gravity() * 0.5
		velocity.y += gravity_factor.clamp(-Vector3(0, 1, 0).normalized() * max_falling_speed, Vector3(0, 1, 0).normalized() * max_falling_speed).y
	
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


func on_ui_changed(new_ui_state: State) -> void:
	if new_ui_state.name == "IdleUIState":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
