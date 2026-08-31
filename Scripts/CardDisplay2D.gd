class_name CardDisplay2D
extends PanelContainer

signal mouse_entered_card
signal mouse_exited_card
signal drag_started
signal targeted_entity(target: Entity)

@export var cost_label: RichTextLabel
@export var name_label: RichTextLabel
@export var art_texture_rect: TextureRect
@export var explanation_label: RichTextLabel
@export var attack_label: RichTextLabel
@export var block_label: RichTextLabel
@export_flags_3d_physics var target_collision_mask: int

var card_resource: CardResource
var is_dragging: bool = false
var base_z_index: int = 0
var active_tween: Tween
var active_offset_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	offset_transform_enabled = true
	offset_transform_visual_only = true


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not is_dragging:
			start_drag()
		elif not event.pressed and is_dragging:
			end_drag()


##This gets called in the playerhand script.
func setup(resource: CardResource) -> void:
	card_resource = resource
	name_label.text = resource.card_name
	cost_label.text = str(resource.energy_cost)
	attack_label.text = str(resource.attack_damage)
	block_label.text = str(resource.block_amount)
	explanation_label.text = resource.explanation
	art_texture_rect.texture = resource.card_texture
	size = custom_minimum_size


func on_mouse_entered() -> void:
	if not is_dragging:
		mouse_entered_card.emit()


func on_mouse_exited() -> void:
	if not is_dragging:
		mouse_exited_card.emit()


func start_drag() -> void:
	is_dragging = true
	z_index = 200
	drag_started.emit()


func end_drag() -> void:
	is_dragging = false
	targeted_entity.emit(find_target_under_mouse())


func find_target_under_mouse() -> Entity:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return null
	var mouse_pos := get_global_mouse_position()
	var from := camera.project_ray_origin(mouse_pos)
	var to := from + camera.project_ray_normal(mouse_pos) * 1000.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = target_collision_mask
	var result := get_viewport().world_3d.direct_space_state.intersect_ray(query)
	var collider: Object = result.get("collider")
	if collider is Entity:
		return collider
	elif collider is VoodooDoll:
		return collider.get_parent().get_parent()
	return null
