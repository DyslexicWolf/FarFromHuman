class_name UIIdleState
extends State

var ui_idle_state: UIIdleState


func _ready() -> void:
	ui_idle_state = self


func _enter() -> void:
	get_tree().paused = false
	ui_idle_state.show()
	call_deferred("input_delay")


func _exit() -> void:
	can_change_state = false
	ui_idle_state.hide()


func _state_physics_process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("CharacterSheet") and can_change_state:
		transitioned.emit(self, "CharacterSheetState")
	elif event.is_action_pressed("PauseGame") and can_change_state:
		transitioned.emit(self, "UIPauseState")
