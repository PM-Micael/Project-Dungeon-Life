# Handle user interaction
extends Window
class_name ProfileWindow

func _ready() -> void:
	title = "Window Manager"
	position = Vector2(0, 0)
	unresizable = true
	borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
