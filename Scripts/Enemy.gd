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
var player: Player

@onready var health_bar: TextureProgressBar = $HealthBar


func _ready() -> void:
	current_health_changed.connect(on_current_health_changed)
	max_health_changed.connect(on_max_health_changed)
	player = get_tree().get_first_node_in_group("Player")
	current_health = max_health
	#This line triggers the max_health_changed signal, otherwise it doesnt get triggered
	#from the export value being set
	max_health = max_health


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	var world_pos := global_position + Vector3(0, 2.5, 0)
	if camera.is_position_behind(world_pos):
		health_bar.visible = false
		return
	health_bar.visible = true

	var screen_pos: Vector2 = camera.unproject_position(world_pos)
	health_bar.position = screen_pos - health_bar.size / 2.0


## Does everything the enemy will do in his turn
func perform_turn(player: Entity) -> void:
	await get_tree().create_timer(0.5).timeout
	perform_random_move(turn_count, player)
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


func on_current_health_changed(value: int) -> void:
	health_bar.value = value


func on_max_health_changed(value: int) -> void:
	health_bar.max_value = value
