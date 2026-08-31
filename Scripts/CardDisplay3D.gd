class_name CardDisplay3D
extends Node3D

@onready var sub_viewport: SubViewport = $SubViewport
@onready var card_mesh: MeshInstance3D = $SM_Card3D/CardDisplay3D
@onready var card_display_2D: CardDisplay2D = $SubViewport/CardDisplay2D


func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = sub_viewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	card_mesh.set_surface_override_material(0, mat)
	get_parent().visible = false


func set_card(card_resource: CardResource) -> void:
	card_display_2D.setup(card_resource)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	get_parent().visible = true


func clear_card() -> void:
	get_parent().visible = false
