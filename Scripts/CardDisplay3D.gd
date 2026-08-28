class_name CardDisplay3D
extends MeshInstance3D

@onready var sub_viewport: SubViewport = $SubViewport


func _ready() -> void:
	var box := BoxMesh.new()
	box.size = Vector3(0.09, 0.126, 0.002)
	mesh = box

	var mat := StandardMaterial3D.new()
	mat.albedo_texture = sub_viewport.get_texture()
	set_surface_override_material(0, mat)
