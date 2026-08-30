class_name RewardBox
extends Button

signal reward_selected(card: CardResource)

@export var card_texture: TextureRect

var card_resource: CardResource


func _ready() -> void:
	pressed.connect(on_pressed)


func setup(card: CardResource) -> void:
	card_resource = card
	card_texture.texture = card.card_texture
	tooltip_text = card.card_name


func on_pressed() -> void:
	if card_resource != null:
		reward_selected.emit(card_resource)
