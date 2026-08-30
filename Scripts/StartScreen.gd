extends Control

@export_file("*.tscn") var game_scene_path: String

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	start_button.pressed.connect(on_start_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	start_button.grab_focus()


func on_start_button_pressed() -> void:
	SceneTransitionManager.change_scene(game_scene_path)


func on_quit_button_pressed() -> void:
	get_tree().quit()
