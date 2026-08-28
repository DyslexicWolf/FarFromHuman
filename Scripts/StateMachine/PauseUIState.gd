class_name PauseUIState
extends State

var pause_ui_state: PauseUIState


func _ready() -> void:
	pause_ui_state = self


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PauseGame") and can_change_state:
		if PlayerUI.in_combat:
			transitioned.emit(self, "CombatUIState")
		else:
			transitioned.emit(self, "IdleUIState")
	elif event.is_action_pressed("CloseUI") and can_change_state:
		if PlayerUI.in_combat:
			transitioned.emit(self, "CombatUIState")
		else:
			transitioned.emit(self, "IdleUIState")


func _enter() -> void:
	get_tree().paused = false
	pause_ui_state.show()
	call_deferred("input_delay")


func _exit() -> void:
	can_change_state = false
	pause_ui_state.hide()


func _state_physics_process(_delta: float) -> void:
	pass
