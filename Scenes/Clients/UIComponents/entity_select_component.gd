extends Control
class_name EntitySelectComponent

signal selected

@export var entity_scene: PackedScene

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

@onready var clickable_entity: ClickableEntity = get_node_or_null("ClickableEntity")

func _ready() -> void:
	var instance = entity_scene.instantiate()
	var entity_sprite: Sprite2D = instance.get_node_or_null("EntitySprite")
	
	if entity_sprite:
		sprite.texture = entity_sprite.texture
	
	instance.queue_free()

func on_selected():
	print("Entity selected")
	selected.emit(entity_scene)
