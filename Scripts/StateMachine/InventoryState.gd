class_name InventoryState
extends State

var inventory_state: InventoryState

@onready var card_tooltip: PanelContainer = $Panel/CardTooltipPanel/CardTooltip


func _ready() -> void:
	inventory_state = self


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Inventory") and can_change_state:
		transitioned.emit(self, "IdleUIState")
	elif event.is_action_pressed("CloseUI") and can_change_state:
		transitioned.emit(self, "IdleUIState")


func _enter() -> void:
	get_tree().paused = false
	inventory_state.show()
	card_tooltip.visible = true
	call_deferred("input_delay")


func _exit() -> void:
	card_tooltip.visible = false
	can_change_state = false
	inventory_state.hide()


func _state_physics_process(_delta: float) -> void:
	pass
