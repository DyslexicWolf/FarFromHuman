extends Node

signal body_part_equipped(box_index: int, card: CardResource)
signal body_part_unequipped(box_index: int)

var body_part_cards: Array[CardResource]
var inventory_cards: Array[CardResource]


func _init() -> void:
	body_part_cards.resize(6)
	inventory_cards.resize(2)


func add_card_to_body_parts(card: CardResource, box_index: int) -> void:
	var new_card := card.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	body_part_cards[box_index] = new_card
	body_part_equipped.emit(box_index, new_card)


func add_card_to_inventory(card: CardResource, box_index: int) -> void:
	var new_card := card.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	inventory_cards[box_index] = new_card


func remove_card_from_body_parts(box_index: int) -> void:
	body_part_cards[box_index] = null
	body_part_unequipped.emit(box_index)


func remove_card_from_inventory(box_index: int) -> void:
	inventory_cards[box_index] = null
