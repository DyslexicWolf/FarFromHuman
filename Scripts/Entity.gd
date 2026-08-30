class_name Entity
extends CharacterBody3D

signal max_health_changed(value: int)
signal current_health_changed(value: int)
signal current_block_changed(value: int)
signal current_weakness_changed(value: int)
signal current_strength_changed(value: int)
signal died(entity: Entity)

const BLOCK_PARTICLES = preload("uid://btutn0xik2sgw")
const BLOOD_PARTICLES = preload("uid://c1c1h1n31bfgm")

@export var entity_name: String

@export var max_health: int:
	set(value):
		max_health = value
		max_health_changed.emit(max_health)
		if current_health > max_health:
			current_health = max_health
			current_health_changed.emit(current_health)
	get:
		return max_health

@export var current_block: int:
	set(value):
		current_block = value
		current_block_changed.emit(current_block)
	get:
		return current_block

@export var current_weakness: int:
	set(value):
		current_weakness = value
		current_weakness_changed.emit(current_weakness)
	get:
		return current_weakness

@export var current_strength: int:
	set(value):
		current_strength = value
		current_strength_changed.emit(current_strength)
	get:
		return current_strength

var current_health: int:
	set(value):
		current_health = clamp(value, -1000, max_health)
		current_health_changed.emit(current_health)
		if current_health <= 0:
			die()
	get:
		return current_health


func die() -> void:
	died.emit(self)
	queue_free()


func take_damage(damage_amount: int) -> void:
	current_health = max(0, current_health - damage_amount)

	var text_to_print: String = "{0} took {1} damage".format([entity_name, damage_amount])
	print(text_to_print)

	var particle_instance := BLOOD_PARTICLES.instantiate()
	particle_instance.position = self.global_position
	get_tree().root.add_child(particle_instance)


func receive_block(block_amount: int) -> void:
	current_block += block_amount

	var text_to_print: String = "{0} received {1} block".format([entity_name, block_amount])
	print(text_to_print)

	var particle_instance := BLOCK_PARTICLES.instantiate()
	particle_instance.position = self.global_position
	get_tree().root.add_child(particle_instance)
