extends Area2D
class_name ClickableEntity

@onready var parent = get_parent()

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		parent.on_clicked()
