extends Node2D
class_name TeamLineupMenu

@onready var player_characters: Array[Entity] # (Self note) Instanciated scenes. NOT added as children
@onready var enemy_characters: Array[Entity]
@onready var board: Node2D = get_node("Board")
@onready var selected_friendly_character

func _ready() -> void:
	place_friendly_characters()

func place_friendly_characters(): # Maybe only run on ready
	var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
	
	var loop_itteration: int = 0
	for c in player_characters:
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
		entity_container_instance.name = "EntityContainer_" + str(loop_itteration+1)
		entity_container_instance.entity = c
		entity_container_instance.position = Vector2(-150+(loop_itteration*100), 250)
		
		var sprite_instance = Sprite2D.new()
		sprite_instance.name = "Sprite2D"
		sprite_instance.texture = c.get_node("Sprite2D").texture
		sprite_instance.scale = Vector2(0.15, 0.15)
		
		entity_container_instance.add_child(sprite_instance)
		board.get_node("Characters").add_child(entity_container_instance)
		
		c.position = sprite_instance.position
		
		loop_itteration += 1
	return
