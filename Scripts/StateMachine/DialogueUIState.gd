class_name DialogueUIState
extends State

var dialogue_ui_state: DialogueUIState


func _ready() -> void:
	dialogue_ui_state = self
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)


func on_dialogue_ended(dialogue: DialogueResource) -> void:
	transitioned.emit(self, "IdleUIState")


func _enter() -> void:
	get_tree().paused = false
	dialogue_ui_state.show()
	call_deferred("input_delay")


func _exit() -> void:
	can_change_state = false
	dialogue_ui_state.hide()


func _state_physics_process(_delta: float) -> void:
	pass
