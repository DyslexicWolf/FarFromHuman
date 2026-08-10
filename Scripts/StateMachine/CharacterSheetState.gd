class_name CharacterSheetState
extends State

var character_sheet_state: CharacterSheetState
var is_box_being_hovered: bool

@onready var card: PanelContainer = $Panel/CardTooltipPanel/Card
@onready var body_parts_panel: Panel = $Panel/BodyPartsPanel
@onready var inventory_panel: Panel = $Panel/InventoryPanel


func _ready() -> void:
	character_sheet_state = self
	for child in body_parts_panel.get_children():
		if child is BodyPartBox:
			child.is_being_hovered.connect(on_child_box_started_hover)
			child.stopped_being_hovered.connect(on_child_box_stopped_hover)

	for child in inventory_panel.get_children():
		if child is InventoryBox:
			child.is_being_hovered.connect(on_child_box_started_hover)
			child.stopped_being_hovered.connect(on_child_box_stopped_hover)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("CharacterSheet") and can_change_state:
		transitioned.emit(self, "UIIdleState")
	elif event.is_action_pressed("CloseUI") and can_change_state:
		transitioned.emit(self, "UIIdleState")

	if event.is_action_pressed("ExtraInfo"):
		card.visible = true
	elif not is_box_being_hovered:
		print("addazda")
		card.visible = false


func _enter() -> void:
	get_tree().paused = false
	character_sheet_state.show()
	call_deferred("input_delay")


func _exit() -> void:
	can_change_state = false
	character_sheet_state.hide()


func _state_physics_process(_delta: float) -> void:
	pass


func on_child_box_started_hover() -> void:
	is_box_being_hovered = true


func on_child_box_stopped_hover() -> void:
	is_box_being_hovered = false
