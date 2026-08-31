class_name VoodooDoll
extends Node3D

@export var body_part_displays: Array[CardDisplay3D] # index must match Inventory.body_part_cards order


func _ready() -> void:
	Inventory.body_part_equipped.connect(_on_body_part_equipped)
	Inventory.body_part_unequipped.connect(_on_body_part_unequipped)

	# sync to whatever's already equipped when this scene loads
	for i in body_part_displays.size():
		var card := Inventory.body_part_cards[i]
		if card:
			body_part_displays[i].set_card(card)
		else:
			body_part_displays[i].clear_card()


func _on_body_part_equipped(box_index: int, card: CardResource) -> void:
	if box_index < body_part_displays.size():
		body_part_displays[box_index].set_card(card)


func _on_body_part_unequipped(box_index: int) -> void:
	if box_index < body_part_displays.size():
		body_part_displays[box_index].clear_card()
