class_name RewardBox
extends Control

signal reward_selected(card: CardResource)

@export var card_texture: TextureRect

var card_resource: CardResource


func setup(card: CardResource) -> void:
	card_resource = card
	card_texture.texture = card.card_texture
	tooltip_text = card.card_name


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("EquipCard"):
		if card_resource:
			take_reward()


func take_reward() -> void:
	reward_selected.emit(card_resource)
