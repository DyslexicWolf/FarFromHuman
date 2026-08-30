class_name ParticleEffect
extends GPUParticles3D


func _ready() -> void:
	finished.connect(on_finished)


func on_finished() -> void:
	queue_free()
