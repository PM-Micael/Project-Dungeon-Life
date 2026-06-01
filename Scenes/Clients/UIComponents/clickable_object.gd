extends Control
class_name ClickableObject

signal left_clicked(entity_container: EntityContainer)
signal right_clicked(entity_container: EntityContainer)
signal tile_left_clicked(tile: Tile)

@onready var entity_container_parent: EntityContainer

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var node = get_parent().get_parent()
				if node is Tile:
					tile_left_clicked.emit(node)
					return
				entity_container_parent = node
				print("Left Clicked " + str(entity_container_parent.entity.name))
				left_clicked.emit(entity_container_parent)
			MOUSE_BUTTON_RIGHT:
				print("Right Clicked")
				right_clicked.emit(entity_container_parent)
