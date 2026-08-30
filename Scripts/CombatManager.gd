class_name CombatManager
extends Node

signal energy_changed(current: int, max: int)
signal played_card(played_card: CardResource)
signal received_new_hand()
signal turn_changed(new_state: CombatState)

enum CombatState {
	PLAYER_TURN,
	ENEMY_TURN,
}

@export var max_energy := 3
@export var cards_per_equipped_body_part := 5
@export var hand_size := 6
@export_file("*.tscn") var game_scene_path: String

var state: CombatState = CombatState.PLAYER_TURN
var current_energy: int = max_energy
var deck_pile: Array[CardResource] = []
var hand_pile: Array[CardResource] = []
var discard_pile: Array[CardResource] = []
var player_hand: PlayerHand
var end_turn_button: Button
var player_energy: PlayerEnergy
var enemies: Array[Enemy] = []
var lootable_card_array: Array[CardResource]
var reward_claimed := false

@onready var combat_rewards: CanvasLayer = $CombatRewards
@onready var custom_item_list: CustomItemList = $CombatRewards/CenterContainer/CustomItemList
@onready var combat_player: Player = $Player


func _ready() -> void:
	for child: State in PlayerUI.get_children():
		if child.visible == true:
			child.transitioned.emit(child, "CombatUIState")
			break
	PlayerUI.in_combat = true

	for child in get_children():
		if child is Enemy:
			child.died.connect(on_enemy_death)
			enemies.append(child)

	player_hand = get_node("/root/PlayerUI/CombatUIState/PlayerHand")
	end_turn_button = get_node("/root/PlayerUI/CombatUIState/EndTurnButton")
	player_energy = get_node("/root/PlayerUI/CombatUIState/PlayerEnergy")

	player_hand.setup(self)
	end_turn_button.pressed.connect(on_end_turn_pressed)
	energy_changed.connect(player_energy.on_player_energy_changed)
	custom_item_list.reward_selected.connect(on_reward_selected)
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
	received_new_hand.emit()


func reshuffle_discard_into_deck() -> void:
	deck_pile = discard_pile.duplicate()
	discard_pile.clear()
	deck_pile.shuffle()


func can_play_card(card: CardResource) -> bool:
	return state == CombatState.PLAYER_TURN and current_energy >= card.energy_cost


##ATTEMPTS to play a card against a target. Returns true if it was played.
func play_card(card: CardResource, target: Entity) -> bool:
	if not can_play_card(card):
		return false
	var idx := hand_pile.find(card)
	if idx == -1:
		return false

	hand_pile.remove_at(idx)
	discard_pile.append(card)
	current_energy -= card.energy_cost
	energy_changed.emit(current_energy, max_energy)
	played_card.emit(card)
	if target is Enemy:
		target.take_damage(card.attack_damage)
	elif target is Player:
		target.receive_block(card.block_amount)
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
	received_new_hand.emit()


func start_enemy_turn() -> void:
	state = CombatState.ENEMY_TURN
	turn_changed.emit(state)
	print("is enemy's turn")

	if combat_player == null:
		push_error("The Player autoload is not an Entity")
		return

	for enemy: Enemy in enemies:
		if is_instance_valid(enemy):
			await enemy.perform_turn(combat_player)

	start_player_turn()


func end_combat() -> void:
	for child: State in PlayerUI.get_children():
		if child.visible == true:
			child.transitioned.emit(child, "IdleUIState")
			break
	PlayerUI.in_combat = false
	SceneTransitionManager.change_scene(game_scene_path)


func show_combat_rewards() -> void:
	custom_item_list.generate_boxes(lootable_card_array)
	combat_rewards.visible = true


func on_reward_selected(card: CardResource) -> void:
	if reward_claimed:
		return

	var inventory_panel := get_node_or_null("/root/PlayerUI/InventoryState/Panel/InventoryPanel")
	if inventory_panel == null:
		push_error("Could not find the player's inventory panel.")
		return

	for child in inventory_panel.get_children():
		if child is InventoryBox and child.card_resource == null:
			reward_claimed = true
			child.card_resource = card
			end_combat()
			return

	push_warning("The reward was not collected because the inventory is full.")


func on_enemy_death(enemy: Enemy) -> void:
	lootable_card_array.append_array(enemy.lootable_cards)
	enemies.erase(enemy)
	if enemies.size() == 0:
		show_combat_rewards()
		print("Combat won.")
