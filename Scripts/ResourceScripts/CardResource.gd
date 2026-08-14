@tool
class_name CardResource
extends Resource

enum BodyPartType {
	HEAD,
	BODY,
	ARM,
	LEG,
}

##Standard card variables that NEED to be filled in for a card to function.
@export_category("Main Variables")
@export var card_name: String = "Example Card"
@export var card_texture: Texture2D = preload("uid://daiinj0p2rp8l")
@export var attack_damage: int = 1
@export var block_amount: int = 1
@export var energy_cost: int = 1
@export_multiline var explanation: String = "A normal attack and a normal block."
@export var body_part_type: BodyPartType


##Extra card variables to make extra effects from the card function.
@export_category("Extra Effects Variables")
@export var weakness_amount: int = 0


func _get_custom_preview_texture() -> Texture2D:
	return card_texture


##Applies the weakness from this card to the target enemy.
func _apply_weakness(entity: Entity) -> Entity:
	entity.weakness_amount += weakness_amount
	return entity
