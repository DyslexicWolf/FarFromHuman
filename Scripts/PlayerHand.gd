class_name PlayerHand
extends Control

const CARD_DISPLAY_SCENE = preload("uid://jms27n0gbn3h")

@export var targeting_arrow: TargetingArrow
@export var fan_radius: float = 900.0
@export var max_fan_angle_degrees: float = 34.0
@export var hover_raise: float = 60.0
@export var base_card_scale: float = 1.0
@export var hover_card_scale: float = 1.12
@export var tween_duration: float = 0.15

var combat_manager: CombatManager
var card_nodes: Array[CardDisplay] = []
var hovered_card: CardDisplay = null
var dragging_card: CardDisplay = null


##Should be called at the start of combat.
##This most likely means inside the combat manager script.
func setup(combat_manager_ref: CombatManager) -> void:
	combat_manager = combat_manager_ref
	combat_manager.hand_changed.connect(refresh_hand)
	resized.connect(layout_hand)
	await get_tree().process_frame
	refresh_hand()


func refresh_hand() -> void:
	for node in card_nodes:
		node.queue_free()
	card_nodes.clear()

	for card_resource in combat_manager.hand_pile:
		var card_ui := CARD_DISPLAY_SCENE.instantiate() as CardDisplay
		add_child(card_ui)
		card_ui.setup(card_resource)
		card_ui.pivot_offset = card_ui.size / 2.0
		card_ui.mouse_entered_card.connect(on_card_hovered.bind(card_ui))
		card_ui.mouse_exited_card.connect(on_card_unhovered.bind(card_ui))
		card_ui.drag_started.connect(on_card_drag_started.bind(card_ui))
		card_ui.dropped_on_target.connect(on_card_dropped.bind(card_ui))
		card_nodes.append(card_ui)

	layout_hand()


func layout_hand() -> void:
	var count := card_nodes.size()
	if count == 0:
		return

	var angle_step := 0.0
	if count > 1:
		angle_step = min(max_fan_angle_degrees, 8.0 * count) / float(count - 1)
	var start_angle := -angle_step * (count - 1) / 2.0
	var pivot := Vector2(size.x / 2.0, size.y + fan_radius - 40.0)

	for i in count:
		var card_ui := card_nodes[i]
		card_ui.z_index = i
		if card_ui == hovered_card or card_ui == dragging_card:
			continue
		var angle_rad := deg_to_rad(start_angle + angle_step * i)
		var offset := Vector2(sin(angle_rad), -cos(angle_rad)) * fan_radius
		var target_pos := pivot + offset - card_ui.size / 2.0
		tween_card(card_ui, target_pos, angle_rad, base_card_scale)


func tween_card(card_ui: CardDisplay, pos: Vector2, rot: float, scale_value: float) -> void:
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT
	)
	tween.tween_property(card_ui, "position", pos, tween_duration)
	tween.tween_property(card_ui, "rotation", rot, tween_duration)
	tween.tween_property(card_ui, "scale", Vector2.ONE * scale_value, tween_duration)


func on_card_hovered(card_ui: CardDisplay) -> void:
	if dragging_card != null:
		return
	hovered_card = card_ui
	card_ui.z_index = 100
	tween_card(card_ui, card_ui.position + Vector2(0, -hover_raise), 0.0, hover_card_scale)


func on_card_unhovered(card_ui: CardDisplay) -> void:
	if hovered_card == card_ui:
		hovered_card = null
	layout_hand()


func on_card_drag_started(card_ui: CardDisplay) -> void:
	dragging_card = card_ui
	hovered_card = null
	if targeting_arrow:
		targeting_arrow.start(card_ui.global_position + card_ui.size / 2.0)


func on_card_dropped(target: Enemy, card_ui: CardDisplay) -> void:
	dragging_card = null
	if targeting_arrow:
		targeting_arrow.stop()
	if target != null and combat_manager.play_card(card_ui.card_resource, target):
		#If the card gets played, combatmanager will refresh the visuals
		#through its signal "hand_changed"
		pass
	else:
		layout_hand()
