extends Node

var keyword_tooltips := {
	"weakness": "A debuff that makes the owner receive X more damage when attacked. Weakness last 2 round by default.",
	"strength": "A buff that makes the owner deal X more damage when attacking. Strength last 2 rounds by default.",
}

const KEYWORD_TOOLTIP = preload("uid://cvidoe53n8hmi")

var _popup: Control
var _popup_label: RichTextLabel


func _ready() -> void:
	_build_popup()


func _build_popup() -> void:
	var tooltip_instance: Control = KEYWORD_TOOLTIP.instantiate()
	_popup = tooltip_instance
	_popup_label = tooltip_instance.get_node("TooltipLabel")
	_popup.visible = false

	var layer := CanvasLayer.new()
	layer.layer = 128
	layer.add_child(tooltip_instance)
	call_deferred("_add_layer_to_tree", layer)


func _add_layer_to_tree(layer: CanvasLayer) -> void:
	get_tree().root.add_child.call_deferred(layer)


func _escape_regex(s: String) -> String:
	var special := ".^$*+?()[]{}|\\"
	var out := ""
	for c in s:
		out += ("\\" + c) if special.find(c) != -1 else c
	return out


##Wraps every known keyword for the given text in [url=keyword]...[/url] so meta signals fire.
func apply_meta_tags(bbcode_text: String) -> String:
	var result := bbcode_text
	for keyword: String in keyword_tooltips.keys():
		var regex := RegEx.new()
		regex.compile("(?i)\\b%s\\b" % _escape_regex(keyword))
		result = regex.sub(result, "[url=%s]$0[/url]" % keyword, true)
	return result


##Call this once per RichTextLabel in their _ready() to set up everything for their keywords.
func register(label: RichTextLabel) -> void:
	label.bbcode_enabled = true
	label.meta_underlined = false
	if not label.meta_hover_started.is_connected(_on_meta_hover_started):
		label.meta_hover_started.connect(_on_meta_hover_started)
	if not label.meta_hover_ended.is_connected(_on_meta_hover_ended):
		label.meta_hover_ended.connect(_on_meta_hover_ended)


func show_tooltip(text: String, screen_pos: Vector2) -> void:
	_popup_label.text = text
	_popup.visible = true
	await get_tree().process_frame
	var offset := Vector2(16, 16)
	var pos := screen_pos + offset
	var viewport_size := get_tree().root.size
	var popup_size: Vector2 = _popup.size
	pos.x = min(pos.x, viewport_size.x - popup_size.x - 8)
	pos.y = min(pos.y, viewport_size.y - popup_size.y - 8)
	_popup.position = pos


func hide_tooltip() -> void:
	_popup.visible = false


func _on_meta_hover_started(meta: Variant) -> void:
	var key := str(meta)
	if keyword_tooltips.has(key):
		show_tooltip(keyword_tooltips[key], get_viewport().get_mouse_position())


func _on_meta_hover_ended(_meta: Variant) -> void:
	hide_tooltip()
