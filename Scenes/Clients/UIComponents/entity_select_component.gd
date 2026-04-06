extends Control
class_name EntitySelectComponent

signal selected

@export var entity: Entity

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

@onready var clickable_entity: ClickableObject = get_node_or_null("ClickableEntity")

func _ready() -> void:
	var entity_sprite: Sprite2D = entity.get_node_or_null("Sprite2D")
	
	if entity_sprite:
		sprite.texture = entity_sprite.texture

func on_clicked():
	selected.emit(entity)
