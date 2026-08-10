class_name CharacterSheetState
extends State

var character_sheet_state: CharacterSheetState


func _ready() -> void:
	character_sheet_state = self


func _enter() -> void:
	get_tree().paused = false
	character_sheet_state.show()
	call_deferred("input_delay")


func _exit() -> void:
	can_change_state = false
	character_sheet_state.hide()


func _state_physics_process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("CharacterSheet") and can_change_state:
		transitioned.emit(self, "UIIdleState")
	elif event.is_action_pressed("CloseUI") and can_change_state:
		transitioned.emit(self, "UIIdleState")
