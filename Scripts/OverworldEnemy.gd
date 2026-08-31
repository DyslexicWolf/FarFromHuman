class_name OverworldEnemy
extends CharacterBody3D

@export var movement_speed: float = 2.0
@export var roaming_radius: float = 10.0
@export var minimum_wait_time: float = 1.0
@export var maximum_wait_time: float = 3.0
@export_file("*.tscn") var combat_scene_path: String

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var roam_timer: Timer = $RoamTimer
@onready var encounter_area: Area3D = $EncounterArea

var roaming_origin: Vector3
var waiting: bool = false
var encounter_started: bool = false


func _ready() -> void:
	roaming_origin = global_position

	roam_timer.timeout.connect(_on_roam_timer_timeout)
	encounter_area.body_entered.connect(_on_body_entered)

	call_deferred("_choose_random_destination")


func _physics_process(delta: float) -> void:
	if encounter_started or waiting:
		velocity.x = 0.0
		velocity.z = 0.0
		_apply_gravity(delta)
		move_and_slide()
		return

	if navigation_agent.is_navigation_finished():
		_begin_waiting()
		return

	var next_position := navigation_agent.get_next_path_position()
	var direction := next_position - global_position
	direction.y = 0.0

	if direction.length_squared() > 0.001:
		direction = direction.normalized()

		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed

		look_at(
			Vector3(next_position.x, global_position.y, next_position.z),
			Vector3.UP,
		)

	_apply_gravity(delta)
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0


func _choose_random_destination() -> void:
	if encounter_started:
		return

	var navigation_map := navigation_agent.get_navigation_map()

	for attempt in 10:
		var angle := randf_range(0.0, TAU)
		var distance := sqrt(randf()) * roaming_radius

		var candidate := roaming_origin + Vector3(
			cos(angle) * distance,
			0.0,
			sin(angle) * distance,
		)

		var navigation_point := NavigationServer3D.map_get_closest_point(
			navigation_map,
			candidate,
		)

		if navigation_point.distance_to(roaming_origin) <= roaming_radius + 1.0:
			navigation_agent.target_position = navigation_point
			return

	_begin_waiting()


func _begin_waiting() -> void:
	if waiting:
		return

	waiting = true
	velocity = Vector3.ZERO

	roam_timer.start(
		randf_range(minimum_wait_time, maximum_wait_time)
	)


func _on_roam_timer_timeout() -> void:
	waiting = false
	_choose_random_destination()


func _on_body_entered(body: Node3D) -> void:
	if encounter_started or not body is Player:
		return

	encounter_started = true
	velocity = Vector3.ZERO

	SceneTransitionManager.start_combat(combat_scene_path)
