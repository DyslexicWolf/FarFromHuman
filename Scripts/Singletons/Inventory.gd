extends Node

var body_part_cards: Array[CardResource]
var inventory_cards: Array[CardResource]


func _init() -> void:
	#a size for the base amount that the player will start with, will need to be adjusted later when we add more slots for bodyparts for the player
	body_part_cards.resize(6)
	inventory_cards.resize(2)


func add_card_to_body_parts(card: CardResource, box_index: int) -> void:
	var new_card := card.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	body_part_cards[box_index] = new_card
	print(body_part_cards)


func add_card_to_inventory(card: CardResource, box_index: int) -> void:
	var new_card := card.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	inventory_cards[box_index] = new_card
	print(inventory_cards)


func remove_card_from_body_parts(box_index: int) -> void:
	body_part_cards[box_index] = null
	print(body_part_cards)


func remove_card_from_inventory(box_index: int) -> void:
	inventory_cards[box_index] = null
	print(inventory_cards)
