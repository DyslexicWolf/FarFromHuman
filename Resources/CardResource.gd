@tool
class_name CardResource
extends Resource

@export var texture: Texture2D = null


func _get_custom_preview_texture() -> Texture2D:
	return texture
