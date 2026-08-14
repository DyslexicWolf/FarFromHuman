class_name Enemy
extends Entity

#placeholder class
@export var enemy_name: String = "Target Dummy 1"
@export var max_health: int = 20

var health: int


func _ready() -> void:
	health = max_health


func take_damage(amount: int) -> void:
	health = max(0, health - amount)
