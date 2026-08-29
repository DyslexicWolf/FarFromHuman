class_name CardDisplay3D
extends Node3D

@export var card_resource_to_display: CardResource

@onready var sub_viewport: SubViewport = $SubViewport
@onready var card_mesh: MeshInstance3D = $SM_Card3D/CardDisplay3D
@onready var card_display_2D: CardDisplay2D = $SubViewport/CardDisplay2D


func _ready() -> void:
	card_display_2D.setup(card_resource_to_display)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = sub_viewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	card_mesh.set_surface_override_material(0, mat)
