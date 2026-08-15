class_name CombatManager
extends Node

signal energy_changed(current: int, max: int)
signal hand_changed
signal turn_changed(new_state: CombatState)

enum CombatState {
	PLAYER_TURN,
	ENEMY_TURN,
}

@export var max_energy := 3
@export var cards_per_equipped_body_part := 5
@export var hand_size := 6

var state: CombatState = CombatState.PLAYER_TURN
var current_energy: int = max_energy
var deck_pile: Array[CardResource] = []
var hand_pile: Array[CardResource] = []
var discard_pile: Array[CardResource] = []
var player_hand: PlayerHand
var end_turn_button: Button
var player_energy: PlayerEnergy


func _ready() -> void:
	for child: State in PlayerUI.get_children():
		if child.visible == true:
			child.transitioned.emit(child, "CombatUIState")
			break
	PlayerUI.in_combat = true

	player_hand = get_node("/root/PlayerUI/CombatUIState/PlayerHand")
	end_turn_button = get_node("/root/PlayerUI/CombatUIState/EndTurnButton")
	player_energy = get_node("/root/PlayerUI/CombatUIState/PlayerEnergy")

	player_hand.setup(self)
	end_turn_button.pressed.connect(on_end_turn_pressed)
	energy_changed.connect(player_energy.on_player_energy_changed)
	build_deck_from_inventory()
	deck_pile.shuffle()
	start_player_turn()


##Builds the deck from the player's currently equipped body parts.
func build_deck_from_inventory() -> void:
	deck_pile.clear()
	var equipped: Array[CardResource] = []
	equipped.append_array(Inventory.body_part_cards)
	for body_part in equipped:
		if body_part == null:
			continue
		for i in cards_per_equipped_body_part:
			deck_pile.append(body_part.duplicate_deep(Resource.DEEP_DUPLICATE_ALL))


func start_player_turn() -> void:
	state = CombatState.PLAYER_TURN
	turn_changed.emit(state)
	current_energy = max_energy
	energy_changed.emit(current_energy, max_energy)
	print("is players turn")
	draw_up_to_hand_size()


func draw_up_to_hand_size() -> void:
	while hand_pile.size() < hand_size:
		if deck_pile.is_empty():
			if discard_pile.is_empty():
				break
			reshuffle_discard_into_deck()
		hand_pile.append(deck_pile.pop_back())
	hand_changed.emit()


func reshuffle_discard_into_deck() -> void:
	deck_pile = discard_pile.duplicate()
	discard_pile.clear()
	deck_pile.shuffle()


func can_play_card(card: CardResource) -> bool:
	return state == CombatState.PLAYER_TURN and current_energy >= card.energy_cost


##ATTEMPTS to play a card against a target. Returns true if it was played.
func play_card(card: CardResource, target: Enemy) -> bool:
	if not can_play_card(card):
		return false
	var idx := hand_pile.find(card)
	if idx == -1:
		return false

	hand_pile.remove_at(idx)
	discard_pile.append(card)
	current_energy -= card.energy_cost
	energy_changed.emit(current_energy, max_energy)
	hand_changed.emit()
	#still need to implement damage, block, extra status effects, ...
	return true


func on_end_turn_pressed() -> void:
	if state != CombatState.PLAYER_TURN:
		return

	discard_hand()
	start_enemy_turn()


func discard_hand() -> void:
	discard_pile.append_array(hand_pile)
	hand_pile.clear()
	hand_changed.emit()


func start_enemy_turn() -> void:
	state = CombatState.ENEMY_TURN
	turn_changed.emit(state)

	#still need to implement the enemy's turn logic here
	print("is enemy's turn")
	start_player_turn()


func end_combat() -> void:
	for child: State in PlayerUI.get_children():
		if child.visible == true:
			child.transitioned.emit(child, "IdleUIState")
			break
	PlayerUI.in_combat = false
