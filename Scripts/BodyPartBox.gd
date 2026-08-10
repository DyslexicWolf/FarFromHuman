class_name BodyPartBox
extends InventoryBox

enum BodyPartType {
	HEAD,
	BODY,
	ARM,
	LEG,
}

@export var bodypart_box_type: BodyPartType


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("EquipCard"):
		if card_resource:
			equip_card()


func equip_card() -> void:
	if inventory_boxes.size() == 0:
		for child in inventory_panel.get_children():
			if child is InventoryBox:
				inventory_boxes.append(child)

	var target_box: InventoryBox = null
	for box in inventory_boxes:
		if box.card_resource == null:
			target_box = box
			break

	if target_box == null:
		return

	target_box.card_resource = card_resource
	card_resource = null
	Inventory.remove_card_from_body_parts(box_index)
