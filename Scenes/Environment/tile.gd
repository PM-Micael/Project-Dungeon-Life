extends Node2D
class_name Tile

@onready var map_tiles_scene: MapTiles = get_parent().get_parent().get_parent()
@onready var friendly_color: ColorRect = $TileStyle/FriendlyColor
@onready var enemy_color: ColorRect = $TileStyle/EnemyColor

func _ready() -> void:
	get_node("ClickableObject/Clickable").tile_left_clicked.connect(_on_tile_clicked)
	if get_parent().get_parent().name == "FriendlySide":
		friendly_color.visible = true
		enemy_color.visible = false
	else:
		enemy_color.visible = true
		friendly_color.visible = false

func _on_tile_clicked(tile: Tile) -> void:
	map_tiles_scene.on_tile_clicked(tile)
