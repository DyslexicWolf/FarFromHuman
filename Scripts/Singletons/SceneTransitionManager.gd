extends Node

const FRACTAL_TRANSITION_SCENE = preload("uid://dnw155i76t8uk")

var _foreground_canvas: CanvasLayer
var _foreground_scene: Control
var _transition_effect: ColorRect
var _transition_tween: Tween
var _transition_effect_parameter_call: Variant = func(value: float) -> void:
	_transition_effect.material.set_shader_parameter("progress", value)
	_transition_effect.material.set_shader_parameter(
		"background_threshold",
		abs(1.0 - value * 2.0) - 0.5,
	)
	_transition_effect.material.set_shader_parameter(
		"color_threshold",
		min(1.0, abs(-4.0 + value * 8.0)) * 0.48,
	)

var combat_return_scene_path: String


func start_combat(combat_scene_path: String) -> void:
	combat_return_scene_path = get_tree().current_scene.scene_file_path
	change_scene(combat_scene_path)


func return_from_combat() -> void:
	if combat_return_scene_path.is_empty():
		push_error("No combat return scene was registered.")
		return

	change_scene(combat_return_scene_path)


func _ready() -> void:
	get_tree().scene_changed.connect(on_scene_changed)
	get_tree().scene_changed.connect(_scene_changed_callback)

	_foreground_canvas = CanvasLayer.new()
	_foreground_canvas.layer = 1000
	add_child(_foreground_canvas)
	_foreground_scene = FRACTAL_TRANSITION_SCENE.instantiate()
	_foreground_canvas.add_child(_foreground_scene)

	_transition_effect = _foreground_scene.get_node_or_null(".")
	if _transition_effect:
		_transition_effect.set_visible(false)


func on_scene_changed() -> void:
	pass


func initialize_variables() -> void:
	pass


func change_scene(scene_path: String) -> void:
	if _transition_effect == null:
		push_warning("Transition effect not found.")
		get_tree().change_scene_to_file(scene_path)
		return
	if _transition_tween != null:
		_transition_tween.kill()
		_transition_tween = null
	_transition_effect.material.set_shader_parameter("seed", randf())
	_transition_effect.set_visible(true)
	_transition_tween = create_tween()
	_transition_tween.tween_method(_transition_effect_parameter_call, 0.0, 0.5, 1.0)
	_transition_tween.tween_callback(get_tree().change_scene_to_file.bind(scene_path))


func _scene_changed_callback() -> void:
	if _transition_tween != null:
		_transition_tween.kill()
		_transition_tween = null

	_transition_tween = create_tween()
	_transition_tween.tween_method(_transition_effect_parameter_call, 0.5, 1.0, 0.75)
	_transition_tween.tween_callback(_transition_effect.set_visible.bind(false))
