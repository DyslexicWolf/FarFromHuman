class_name CustomItemList
extends ScrollContainer

signal reward_selected(card: CardResource)

@export var columns: int = 5
@export var card_list: Array[CardResource]
@export var box: PackedScene = preload("res://Prefabs/UI/RewardBox.tscn")
@export var box_size := 120
@export var y_size := 360
@export var scroll_bar_offset := 30
@export var item_offset := Vector2(0, 0)

var box_nodes: Array[RewardBox]

@onready var v_box_container := $VBoxContainer


##Clears inventory boxes and generates new list from given array
func generate_boxes(cards: Array[CardResource]) -> void:
	card_list = cards
	for i in v_box_container.get_children():
		i.queue_free()
	box_nodes.clear()
	var rows := int(ceil(float(card_list.size()) / float(columns)))
	var current_index := -1
	var cols := columns
	if cards.size() < columns:
		cols = cards.size()

	self.custom_minimum_size.x = cols * (box_size + item_offset.x) + scroll_bar_offset
	self.custom_minimum_size.y = y_size

	self.size.y = self.custom_minimum_size.y
	self.size.x = self.custom_minimum_size.x

	for i in rows:
		var h_box_container := create_h_box_container(cols)
		for j in cols:
			current_index += 1
			if card_list.size() <= current_index:
				break
			var instance: RewardBox = box.instantiate()
			instance.custom_minimum_size += item_offset
			box_nodes.append(instance)
			h_box_container.add_child(instance)
			instance.setup(card_list[current_index])
			instance.reward_selected.connect(on_reward_selected)
		v_box_container.add_child(h_box_container)


func create_h_box_container(cols: int) -> HBoxContainer:
	var container := HBoxContainer.new()
	container.custom_minimum_size.x = cols * (box_size + item_offset.x)
	container.custom_minimum_size.y = box_size + item_offset.y
	return container


func on_reward_selected(card: CardResource) -> void:
	reward_selected.emit(card)


func get_box_nodes() -> Array[RewardBox]:
	return box_nodes
