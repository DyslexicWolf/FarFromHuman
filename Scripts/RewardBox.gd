class_name RewardBox
extends Control

signal reward_selected(card: CardResource)

@export var card_texture: TextureRect

var card_resource: CardResource


func setup(card: CardResource) -> void:
	card_resource = card
	card_texture.texture = card.card_texture


func _make_custom_tooltip(_for_text: String) -> Object:
	if not card_resource:
		return
	var tooltip_instance := preload("uid://dkeiv76ehlj46").instantiate()
	var tooltip_instance_text := tooltip_instance.get_node("Text")

	tooltip_instance_text.text = card_resource.card_name
	return tooltip_instance


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("EquipCard"):
		if card_resource:
			take_reward()


func take_reward() -> void:
	reward_selected.emit(card_resource)
