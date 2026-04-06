extends Node2D
class_name MapTiles

signal tile_clicked

func on_tile_clicked(tile: Tile):
	tile_clicked.emit(tile)
