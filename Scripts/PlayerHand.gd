class_name PlayerHand
extends Control

@export var targeting_arrow: TargetingArrow
@export var discard_pile: Control
@export var deck_pile: Control
@export var min_fan_radius: float = 1000.0
@export var max_fan_radius: float = 1200.0
@export var full_fan_card_count: int = 8
@export var max_fan_angle_degrees: float = 34.0
@export var hover_raise: float = 60.0
@export var base_card_scale: float = 1.0
@export var hover_card_scale: float = 1.12
@export var tween_duration: float = 0.15
@export var card_hand_y_offset: float = 175.0

var combat_manager: CombatManager
var card_nodes: Array[CardDisplay2D] = []
var hovered_card: CardDisplay2D = null
var dragging_card: CardDisplay2D = null
var card_display_scene: CardDisplay2D


func _ready() -> void:
	card_display_scene = get_node("/root/PlayerUI/CombatUIState/PlayerHand/CardDisplay2D")


##Should be called at the start of combat.
##This most likely means inside the combat manager script.
func setup(combat_manager_ref: CombatManager) -> void:
	combat_manager = combat_manager_ref
	combat_manager.received_new_hand.connect(refresh_hand)
	combat_manager.played_card.connect(on_card_played)
	resized.connect(layout_hand.bind(false))
	await get_tree().process_frame
	refresh_hand()


##Fully (re)builds the player's hand. Only intended for drawing up to handsize
##and when discarding the remaining cards left when the player ends their turn.
func refresh_hand() -> void:
	for node in card_nodes:
		node.queue_free()
	card_nodes.clear()
	for card_resource in combat_manager.hand_pile:
		var card_display := card_display_scene.duplicate()
		add_child(card_display)
		card_display.setup(card_resource)
		card_display.pivot_offset = card_display.size / 2.0
		card_display.mouse_entered_card.connect(on_card_hovered.bind(card_display))
		card_display.mouse_exited_card.connect(on_card_unhovered.bind(card_display))
		card_display.drag_started.connect(on_card_drag_started.bind(card_display))
		card_display.targeted_entity.connect(on_targeted_entity.bind(card_display))
		card_display.visible = true
		card_nodes.append(card_display)
	layout_hand(true)


##Removes the card's visuals from the playershand.
func on_card_played(card: CardResource) -> void:
	var played_index := -1
	for i in card_nodes.size():
		if card_nodes[i].card_resource == card:
			played_index = i
			break
	if played_index == -1:
		return

	var card_display := card_nodes[played_index]
	card_nodes.remove_at(played_index)

	if hovered_card == card_display:
		hovered_card = null
	if dragging_card == card_display:
		dragging_card = null

	tween_to_discard(card_display)
	layout_hand(false)


func current_fan_radius(count: int) -> float:
	var t: float = clamp(float(count) / float(full_fan_card_count), 0.0, 1.0)
	return lerp(min_fan_radius, max_fan_radius, t)


func layout_hand(from_deck: bool) -> void:
	var count := card_nodes.size()
	if count == 0:
		return
	var radius := current_fan_radius(count)
	var angle_step := 0.0
	if count > 1:
		angle_step = min(max_fan_angle_degrees, 8.0 * count) / float(count - 1)
	var start_angle := -angle_step * (count - 1) / 2.0
	var pivot := Vector2(size.x / 2.0, size.y + radius - card_hand_y_offset)
	for i in count:
		var card_display := card_nodes[i]
		card_display.base_z_index = i
		card_display.z_index = i
		var angle_rad := deg_to_rad(start_angle + angle_step * i)
		var offset := Vector2(sin(angle_rad), -cos(angle_rad)) * radius
		var target_pos := pivot + offset - card_display.size / 2.0
		tween_to_hand(card_display, target_pos, angle_rad, base_card_scale, from_deck)


##This function makes the cards visually move from the deck to the player's hand.
func tween_to_hand(
	card_display: CardDisplay2D,
	pos: Vector2,
	rot: float,
	scaling: float,
	from_deck: bool,
) -> void:
	if card_display.active_tween:
		card_display.active_tween.kill()

	if from_deck and deck_pile:
		card_display.global_position = (
			deck_pile.global_position + deck_pile.size / 2.0 - card_display.size / 2.0
		)
		card_display.rotation = 0.0
		card_display.scale = Vector2.ONE * base_card_scale

	var fly_duration := tween_duration * 2.5
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT
	)
	tween.tween_property(card_display, "position", pos, fly_duration)
	tween.tween_property(card_display, "rotation", rot, fly_duration)
	tween.tween_property(card_display, "scale", Vector2.ONE * scaling, fly_duration)
	card_display.active_tween = tween


##Makes a visual offset happen for the cards when hovering them.
##This uses the offset_transform so only the visuals get moved, rotated, scaled.
func tween_card_offset(
	card_display: CardDisplay2D,
	pos: Vector2,
	rot: float,
	scaling: float,
) -> void:
	if card_display.active_offset_tween:
		card_display.active_offset_tween.kill()
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT
	)

	tween.tween_property(card_display, "offset_transform_position", pos, tween_duration)
	tween.tween_property(card_display, "offset_transform_rotation", rot, tween_duration)
	var scale_value := Vector2.ONE * scaling

	tween.tween_property(card_display, "offset_transform_scale", scale_value, tween_duration)
	card_display.active_offset_tween = tween


##This function makes the card visually move to the discard pile.
func tween_to_discard(card_display: CardDisplay2D) -> void:
	if card_display.active_tween:
		card_display.active_tween.kill()
	if card_display.active_offset_tween:
		card_display.active_offset_tween.kill()

	card_display.offset_transform_position = Vector2.ZERO
	card_display.offset_transform_rotation = 0.0
	card_display.offset_transform_scale = Vector2.ONE
	card_display.z_index = 300

	var target_pos: Vector2
	if discard_pile:
		target_pos = (
			discard_pile.global_position + discard_pile.size / 2.0 - card_display.size / 2.0
		)

	var fly_duration := tween_duration * 2.5
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_IN
	)
	tween.tween_property(card_display, "global_position", target_pos, fly_duration)
	tween.tween_property(
		card_display,
		"rotation",
		card_display.rotation + deg_to_rad(20.0),
		fly_duration,
	)
	tween.tween_property(card_display, "scale", Vector2.ONE * 0.35, fly_duration)
	card_display.active_tween = tween
	tween.chain().tween_callback(card_display.queue_free)


func apply_lifted_offset(card_display: CardDisplay2D) -> void:
	card_display.z_index = 200 if card_display == dragging_card else 100
	var scale_value := hover_card_scale / base_card_scale
	tween_card_offset(card_display, Vector2(0, -hover_raise), -card_display.rotation, scale_value)


func clear_lifted_offset(card_display: CardDisplay2D) -> void:
	card_display.z_index = card_display.base_z_index
	tween_card_offset(card_display, Vector2.ZERO, 0.0, 1.0)


func on_card_hovered(card_display: CardDisplay2D) -> void:
	if dragging_card != null:
		return
	hovered_card = card_display
	apply_lifted_offset(card_display)


func on_card_unhovered(card_display: CardDisplay2D) -> void:
	if hovered_card == card_display:
		hovered_card = null
	clear_lifted_offset(card_display)


func on_card_drag_started(card_display: CardDisplay2D) -> void:
	dragging_card = card_display
	hovered_card = null
	apply_lifted_offset(card_display)
	if targeting_arrow:
		targeting_arrow.start(card_display.global_position + card_display.size / 2.0)


func on_targeted_entity(target: Entity, card_display: CardDisplay2D) -> void:
	dragging_card = null
	if targeting_arrow:
		targeting_arrow.stop()
	if target != null and combat_manager.play_card(card_display.card_resource, target):
		#If the card gets played, combat_manager's "played_card" signal will
		#remove this node and re-layout the remaining hand
		pass
	else:
		clear_lifted_offset(card_display)
