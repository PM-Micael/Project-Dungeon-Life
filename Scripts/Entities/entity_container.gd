extends Node2D
class_name EntityContainer

@onready var entity: Entity:
	set(value):
		entity = value
		_set_sprite()

func _set_sprite():
	var sprite: Sprite2D = get_child(0)
	if entity != null:
		sprite.position = entity.get_node("Sprite/Sprite2D").position
		sprite.texture = entity.get_node("Sprite/Sprite2D").texture
		return
	
	sprite.texture = null

func on_clicked():
	get_parent().entity_container_clicked(self)

func on_right_click_option_selected(id: int):
	get_parent().on_right_click_option_selected(id, self)
	print("EntityContainer right clicked")
