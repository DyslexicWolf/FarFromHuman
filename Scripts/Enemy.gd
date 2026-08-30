class_name Enemy
extends Entity

# enum EnemyAction {
# 	SOFT_ATTACK,
# 	HARD_ATTACK,
# 	DEFEND,
# }
# 
# @export var possible_actions: Array[EnemyAction] = [
# 	EnemyAction.SOFT_ATTACK,
# 	EnemyAction.HARD_ATTACK,
# 	EnemyAction.DEFEND,
# ]

@export var soft_attack_damage: int = 2
@export var hard_attack_damage: int = 5
@export var defense_amount: int = 3

@export var lootable_cards: Array[CardResource]

var turn_count: int = 0


func _ready() -> void:
	current_health = max_health
	
## Does everything the enemy will do in his turn
func perform_turn(player: Entity) -> void:
	await get_tree().create_timer(0.5).timeout
	perform_random_move(turn_count,player)
	await get_tree().create_timer(0.5).timeout
	turn_count += 1
	return
	
## Will perform a random move for now
func perform_random_move(turn: int, player: Entity) -> void:
	match turn % 3:
		0:
			player.take_damage(soft_attack_damage)
		1:
			self.receive_block(defense_amount)
		2:
			player.take_damage(hard_attack_damage)
