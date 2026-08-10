class_name PlayerUI
extends Node

@onready var character_sheet: Panel = $CharacterSheet


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("CharacterSheet"):
		character_sheet.visible = not character_sheet.visible
	elif event.is_action_pressed("CloseUI"):
		for child in self.get_children():
			if child.visible == true:
				child.visible = false
