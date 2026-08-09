class_name InventoryBox
extends Node

@onready var card_texture: TextureRect = $CardTexture

var card: CardResource:
	set(value):
		card = value
		_on_card_changed()
	get:
		return card


func _on_card_changed() -> void:
	if not card:
		card_texture.texture = null
		return

	card_texture.texture = card.texture


func _make_custom_tooltip(_for_text: String) -> Object:
	if not card:
		return
	var tooltip_instance: PanelContainer = preload("uid://b5dgysfbqkqbf").instantiate()
	var card_cost: RichTextLabel = tooltip_instance.get_node("MarginContainerCost/CardCost")
	var card_name: RichTextLabel = tooltip_instance.get_node("VBoxContainer/MarginContainerName/CardName")
	var card_explanation: RichTextLabel = tooltip_instance.get_node("VBoxContainer/MarginContainerExplanation/CardExplanation")
	var card_attack: RichTextLabel = tooltip_instance.get_node("MarginContainerAttackstat/CardAttackstat")
	var card_block: RichTextLabel = tooltip_instance.get_node("MarginContainerBlockstat/CardBlockstat")

	card_cost.text = str(card.energy_cost)
	card_name.text = card.card_name
	card_explanation.text = card.explanation
	card_attack.text = str(card.attack_damage)
	card_block.text = str(card.block_amount)

	return tooltip_instance
