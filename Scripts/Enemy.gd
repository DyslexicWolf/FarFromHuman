class_name Enemy
extends Entity

@export var lootable_cards: Array[CardResource]


func _ready() -> void:
	current_health = max_health
