extends Control

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(on_start_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	start_button.grab_focus()


func on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func on_quit_button_pressed() -> void:
	get_tree().quit()
