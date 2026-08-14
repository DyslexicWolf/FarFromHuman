class_name Player
extends Entity


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		get_tree().change_scene_to_file("res://Scenes/Combat.tscn")
