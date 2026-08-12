class_name CharacterSheetState
extends State

var character_sheet_state: CharacterSheetState

@onready var card_tooltip: PanelContainer = $Panel/CardTooltipPanel/CardTooltip


func _ready() -> void:
	character_sheet_state = self


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("CharacterSheet") and can_change_state:
		transitioned.emit(self, "UIIdleState")
	elif event.is_action_pressed("CloseUI") and can_change_state:
		transitioned.emit(self, "UIIdleState")


func _enter() -> void:
	get_tree().paused = false
	character_sheet_state.show()
	card_tooltip.visible = true
	call_deferred("input_delay")


func _exit() -> void:
	card_tooltip.visible = false
	can_change_state = false
	character_sheet_state.hide()


func _state_physics_process(_delta: float) -> void:
	pass
