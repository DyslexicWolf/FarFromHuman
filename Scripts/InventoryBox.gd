class_name InventoryBox
extends Control

@onready var card_texture: TextureRect = $CardTexture

var card_resource: CardResource:
	set(value):
		card_resource = value
		_on_card_changed()
		if self is BodyPartBox and card_resource != null:
			Inventory.add_card_to_body_parts(card_resource, box_index)
		elif self is InventoryBox and card_resource != null:
			Inventory.add_card_to_inventory(card_resource, box_index)
	get:
		return card_resource

var body_part_boxes: Array[BodyPartBox]
var inventory_boxes: Array[InventoryBox]

@export var starting_card: CardResource
@export var box_index: int
@export var body_parts_panel: Panel
@export var inventory_panel: Panel
@export var card_tooltip: PanelContainer


func _ready() -> void:
	card_resource = starting_card
	mouse_entered.connect(on_mouse_entered)


func _on_card_changed() -> void:
	if not card_resource:
		card_texture.texture = null
		return

	card_texture.texture = card_resource.card_texture


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("EquipCard"):
		if card_resource:
			equip_card()


func equip_card() -> void:
	if body_part_boxes.size() == 0:
		for child in body_parts_panel.get_children():
			if child is BodyPartBox:
				body_part_boxes.append(child)

	var target_box: BodyPartBox = null
	var viable_boxes: Array[BodyPartBox]

	for box in body_part_boxes:
		if card_resource.body_part_type == box.bodypart_box_type:
			viable_boxes.append(box)

	for box in viable_boxes:
		if box.card_resource == null:
			target_box = box
			break

	if target_box == null:
		target_box = viable_boxes[0]

	if target_box.card_resource == null:
		target_box.card_resource = card_resource
		card_resource = null
	else:
		var new_card_resource: CardResource = target_box.card_resource
		target_box.card_resource = card_resource
		card_resource = new_card_resource

	Inventory.remove_card_from_inventory(box_index)


func on_mouse_entered() -> void:
	if card_resource == null:
		return

	var card_cost := card_tooltip.get_node("MarginContainerCost/CardCost")
	var card_name := card_tooltip.get_node("VBoxContainer/MarginContainerName/CardName")
	var card_art := card_tooltip.get_node("VBoxContainer/MarginContainerArt/CardArt")
	var card_explanation := card_tooltip.get_node(
		"VBoxContainer/MarginContainerExplanation/CardExplanation"
	)
	var card_attack := card_tooltip.get_node("MarginContainerAttackstat/CardAttackstat")
	var card_block := card_tooltip.get_node("MarginContainerBlockstat/CardBlockstat")

	card_cost.text = str(card_resource.energy_cost)
	card_name.text = card_resource.card_name
	card_art.texture = card_resource.card_texture
	card_explanation.text = KeywordGlossary.apply_meta_tags(card_resource.explanation)
	card_attack.text = str(card_resource.attack_damage)
	card_block.text = str(card_resource.block_amount)

	if card_tooltip.visible == false:
		card_tooltip.visible = true
