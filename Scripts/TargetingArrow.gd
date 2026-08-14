class_name TargetingArrow
extends Node2D

@export var line_width: float = 6.0
@export var line_color: Color = Color(1.0, 0.85, 0.2, 0.9)

var _line: Line2D
var _active: bool = false
var _start_position: Vector2


func _ready() -> void:
	_line = Line2D.new()
	_line.width = line_width
	_line.default_color = line_color
	add_child(_line)
	visible = false


func start(from_position: Vector2) -> void:
	_start_position = from_position
	_active = true
	visible = true


func stop() -> void:
	_active = false
	visible = false


func _process(_delta: float) -> void:
	if not _active:
		return
	_line.points = [_start_position, get_global_mouse_position()]
