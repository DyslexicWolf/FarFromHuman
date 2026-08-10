class_name UIPauseState
extends State

var ui_pause_state: UIPauseState


func _ready() -> void:
	ui_pause_state = self


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PauseGame") and can_change_state:
		transitioned.emit(self, "UIIdleState")
	elif event.is_action_pressed("CloseUI") and can_change_state:
		transitioned.emit(self, "UIIdleState")


func _enter() -> void:
	get_tree().paused = false
	ui_pause_state.show()
	call_deferred("input_delay")


func _exit() -> void:
	can_change_state = false
	ui_pause_state.hide()


func _state_physics_process(_delta: float) -> void:
	pass
