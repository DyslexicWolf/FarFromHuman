class_name VoodooDoll
extends Node3D

@export var body_part_displays: Array[CardDisplay3D] # index must match Inventory.body_part_cards order
@export_range(0.0, 1.0) var maximum_blood_intensity: float = 1.0

@onready var doll_mesh: MeshInstance3D = $SM_VoodooDoll/Cube

var health_source: Entity
var blood_material: ShaderMaterial

func _ready() -> void:
	Inventory.body_part_equipped.connect(_on_body_part_equipped)
	Inventory.body_part_unequipped.connect(_on_body_part_unequipped)

	# sync to whatever's already equipped when this scene loads
	for i in body_part_displays.size():
		var card := Inventory.body_part_cards[i]
		if card:
			body_part_displays[i].set_card(card)
		else:
			body_part_displays[i].clear_card()
			
	_setup_health_visual()

func _setup_health_visual() -> void:
	health_source = _find_health_source()

	if health_source == null:
		push_warning("VoodooDoll could not find its owning Entity.")
		return

	var configured_material := doll_mesh.material_overlay as ShaderMaterial

	if configured_material == null:
		push_warning("The doll has no blood ShaderMaterial assigned as Material Overlay.")
		return

	# Each doll receives its own material instance.
	blood_material = configured_material.duplicate() as ShaderMaterial
	doll_mesh.material_overlay = blood_material

	health_source.current_health_changed.connect(_on_current_health_changed)
	health_source.max_health_changed.connect(_on_max_health_changed)

	# Wait until Player._ready has initialized current_health.
	call_deferred("_refresh_blood")
	
func _find_health_source() -> Entity:
	var ancestor := get_parent()

	while ancestor != null:
		if ancestor is Entity:
			return ancestor as Entity

		ancestor = ancestor.get_parent()

	return null


func _refresh_blood() -> void:
	if health_source != null:
		_update_blood_intensity(health_source.current_health)


func _on_current_health_changed(new_health: int) -> void:
	_update_blood_intensity(new_health)


func _on_max_health_changed(_new_maximum: int) -> void:
	_refresh_blood()


func _update_blood_intensity(new_health: int) -> void:
	if blood_material == null or health_source.max_health <= 0:
		return

	var health_ratio := clampf(
		float(new_health) / float(health_source.max_health),
		0.0,
		1.0,
	)

	var missing_health_ratio := 1.0 - health_ratio
	var intensity := missing_health_ratio * maximum_blood_intensity

	blood_material.set_shader_parameter("intensity", intensity)


func _on_body_part_equipped(box_index: int, card: CardResource) -> void:
	if box_index < body_part_displays.size():
		body_part_displays[box_index].set_card(card)


func _on_body_part_unequipped(box_index: int) -> void:
	if box_index < body_part_displays.size():
		body_part_displays[box_index].clear_card()
