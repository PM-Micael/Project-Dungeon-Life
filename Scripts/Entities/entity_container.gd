extends Node2D
class_name EntityContainer

@onready var entity: Entity:
	set(value):
		entity = value
		_set_sprite()

func _ready() -> void:
	_set_sprite()

func _set_sprite():
	var sprite: Sprite2D = get_child(0)
	sprite.texture = entity.get_node("Sprite2D").texture

func on_clicked():
	get_parent().entity_container_clicked(self)
