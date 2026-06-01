extends Node2D
class_name Tile

@onready var map_tiles_scene: MapTiles = get_parent().get_parent().get_parent()

func _ready() -> void:
	get_node("ClickableObject/Clickable").tile_left_clicked.connect(_on_tile_clicked)

func _on_tile_clicked(tile: Tile) -> void:
	map_tiles_scene.on_tile_clicked(tile)
