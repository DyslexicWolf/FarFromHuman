extends Entity

@export var acceleration: float = 2.0
@export var drag: float = 500.0
@export var max_movement_speed: float = 10.0
@export var mouse_sensitivity: float = 0.003
@export var min_pitch: float = -80.0
@export var max_pitch: float = 80.0

@onready var player_camera: Camera3D = $PlayerCamera

var input_vector: Vector2
var in_ui_idle_state: bool


func _ready() -> void:
	current_health = max_health
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PlayerUI.ui_changed.connect(on_ui_changed)


func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("CombatTest"):
		get_tree().change_scene_to_file("res://Scenes/Combat.tscn")

	if event.is_action_pressed("UICancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)

		player_camera.rotate_x(-event.relative.y * mouse_sensitivity)
		player_camera.rotation.x = clamp(
			player_camera.rotation.x,
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch),
		)


func get_input() -> void:
	input_vector = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")

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
			desired_input_direction.x * max_movement_speed,
			acceleration,
		)
		velocity.z = move_toward(
			velocity.z,
			desired_input_direction.z * max_movement_speed,
			acceleration,
		)
	else:
		velocity.x = move_toward(velocity.x, 0, drag)
		velocity.z = move_toward(velocity.z, 0, drag)


func on_ui_changed(new_ui_state: State) -> void:
	if new_ui_state.name == "IdleUIState":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
