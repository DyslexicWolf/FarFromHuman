@tool
class_name CardResource
extends Resource

##Standard card variables that NEED to be filled in for a card to function.
@export var card_name: String = "Example Card"
@export var card_texture: Texture2D = preload("uid://daiinj0p2rp8l")
@export var attack_damage: int = 1
@export var block_amount: int = 1
@export var energy_cost: int = 1
@export var explanation: String = "A normal attack and a normal block."

##Extra card variables to make extra effects from the card function.
@export var weakness_amount: int = 0


func _get_custom_preview_texture() -> Texture2D:
	return card_texture


##Applies the weakness from this card to the target enemy.
func _apply_weakness(enemy: Enemy) -> Enemy:
	enemy.weakness_amount += weakness_amount
	return enemy
