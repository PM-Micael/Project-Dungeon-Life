# Handle user interaction
extends Window
class_name SettingsWindow

func _ready() -> void:
	title = "Settings Window"
	position = Vector2(490, 219)
	unresizable = true
	borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
