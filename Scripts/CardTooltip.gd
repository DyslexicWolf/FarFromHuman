class_name CardTooltip
extends Control


func _ready() -> void:
	var popup_panel: PopupPanel = get_parent()
	popup_panel.visible = false
	resize_and_move_tooltip(popup_panel)


func resize_and_move_tooltip(popup_panel: PopupPanel) -> void:
	await get_tree().physics_frame
	await get_tree().process_frame
	popup_panel.position = Vector2(1300, 75)
	popup_panel.visible = true
