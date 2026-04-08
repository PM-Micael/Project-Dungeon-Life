extends Node2D
class_name TeamLineupMenu

@onready var board: GameBoard = get_node("Board")
@onready var map_tiles_scene: MapTiles = get_node_or_null("Board/MapTiles")
@onready var ui_scene: Control = get_node_or_null("UI")

@onready var currently_selected_tile: Tile
@onready var currently_selected_character: Entity

func _ready() -> void:
	map_tiles_scene.tile_clicked.connect(_on_tile_clicked)
	create_fiendly_characters_on_ui()
	place_friendly_characters_board()
	_load_enemy_units()
	place_enemy_characters_board()

func _load_enemy_units(): #´Hardcoded palceholder
	var enemies: Array[PackedScene] = [
		load("res://Scenes/Characters/skeleton.tscn"),
		load("res://Scenes/Characters/skeleton.tscn"),
		load("res://Scenes/Characters/skeleton.tscn"),
		load("res://Scenes/Characters/skeleton.tscn"),
	]
	
	for scene in enemies:
		var instance: Entity = scene.instantiate()
		board.enemy_units.append(instance)

func create_fiendly_characters_on_ui():
	var entity_select_component_scene: PackedScene = load(("res://Scenes/Clients/UIComponents/entity_select_component.tscn"))
	var loop_itteration: int = 0
	var column: int = 1
	for c in Globals.dungeon_team:
		var entity_select_component_instance: EntitySelectComponent = entity_select_component_scene.instantiate()
		entity_select_component_instance.selected.connect(place_friendly_characters_ui)
		entity_select_component_instance.entity = c
		entity_select_component_instance.scale = Vector2(0.25, 0.25)
		entity_select_component_instance.position = Vector2(-600*column, -300+(loop_itteration*200))
		
		ui_scene.get_node("FriendlyCharacterContainers").add_child(entity_select_component_instance)
		loop_itteration += 1

func place_friendly_characters_board(): # Maybe only run on ready
	var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
	
	var loop_itteration: int = 0
	for c in Globals.dungeon_team:
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
		entity_container_instance.name = "EntityContainer_" + str(loop_itteration+1)
		entity_container_instance.entity = c
		entity_container_instance.position = Vector2(-150+(loop_itteration*100), 250)
		c.starting_position = entity_container_instance.position
		
		var sprite_instance = Sprite2D.new()
		sprite_instance.name = "Sprite2D"
		sprite_instance.texture = c.get_node("Sprite2D").texture
		sprite_instance.scale = Vector2(0.15, 0.15)
		
		entity_container_instance.add_child(sprite_instance)
		board.get_node("Characters/FriendlyUnits").add_child(entity_container_instance)
		
		loop_itteration += 1

func place_enemy_characters_board(): # Maybe only run on ready
	var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
	
	var loop_itteration: int = 0
	for c in board.enemy_units:
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
		entity_container_instance.name = "EntityContainer_" + str(loop_itteration+1)
		entity_container_instance.entity = c
		entity_container_instance.position = Vector2(-150+(loop_itteration*100), -250)
		c.starting_position = entity_container_instance.position
		
		var sprite_instance = Sprite2D.new()
		sprite_instance.name = "Sprite2D"
		sprite_instance.texture = c.get_node("Sprite2D").texture
		sprite_instance.scale = Vector2(0.15, 0.15)
		
		entity_container_instance.add_child(sprite_instance)
		board.get_node("Characters/EnemyUnits").add_child(entity_container_instance)
		
		c.position = sprite_instance.position
		
		loop_itteration += 1

func place_friendly_characters_ui(entity: Entity):
	currently_selected_character = entity
	place_character_on_tile()

func _on_tile_clicked(tile: Tile):
	currently_selected_tile = tile
	place_character_on_tile()

func _on_character_clicked(entity_select_component: EntitySelectComponent):
	#entity_select_component.entity = currently_selected_character
	place_character_on_tile()

func place_character_on_tile():
	if currently_selected_character == null:
		print("Select character")
		return
	elif currently_selected_tile == null:
		print("Select tile")
		return
	
	
	for c in Globals.dungeon_team:
		if c == currently_selected_character:
			c.position.x = currently_selected_tile.position.x + 50
			c.position.y = currently_selected_tile.position.y + 50
			c.starting_position = c.position
		
			var instances: Array[Node] = get_node("Board/Characters/FriendlyUnits").get_children()
			for i in instances:
				if i.entity == c:
					i.position = c.position
					break
	
	currently_selected_tile = null
