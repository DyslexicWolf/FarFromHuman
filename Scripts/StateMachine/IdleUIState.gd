class_name IdleUIState
extends State

var idle_ui_state: IdleUIState


func _ready() -> void:
	idle_ui_state = self


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Inventory") and can_change_state:
		transitioned.emit(self, "InventoryState")
	elif event.is_action_pressed("PauseGame") and can_change_state:
		transitioned.emit(self, "PauseUIState")


func _enter() -> void:
	get_tree().paused = false
	idle_ui_state.show()
	call_deferred("input_delay")


func _exit() -> void:
	can_change_state = false
	idle_ui_state.hide()


func _state_physics_process(_delta: float) -> void:
	pass
