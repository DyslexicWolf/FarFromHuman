class_name SceneTransitionArea3D
extends Area3D

@export_file("*.tscn") var target_scene_path: String

var transition_started: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if transition_started or not body is Player:
		return
	if target_scene_path.is_empty():
		push_warning("SceneTransitionArea3D has no target scene configured.")
		return

	transition_started = true
	monitoring = false
	SceneTransitionManager.change_scene(target_scene_path)
