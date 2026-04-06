extends Node2D
class_name Tile

@onready var map_tiles_scene: MapTiles = get_parent().get_parent().get_parent()

func on_clicked():
	map_tiles_scene.on_tile_clicked(self)
