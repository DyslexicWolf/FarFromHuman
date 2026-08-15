class_name PlayerEnergy
extends RichTextLabel


func on_player_energy_changed(current_energy: int, max_energy: int) -> void:
	text = "Energy: {0}/{1}".format([current_energy, max_energy])
