class_name Card
extends RichTextLabel

@onready var card_explanation: RichTextLabel = $VBoxContainer/MarginContainerExplanation/CardExplanation


func _ready() -> void:
	meta_hover_started.connect(on_meta_hover_started)
