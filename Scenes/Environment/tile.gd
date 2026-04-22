extends Node2D
class_name Tile

@onready var map_tiles_scene: MapTiles = get_parent().get_parent().get_parent()

func _ready() -> void:
	get_node("ClickableObject").get_node("PopupMenu").menu_type = PopupMenuType.Type.NONE

func on_clicked():
	map_tiles_scene.on_tile_clicked(self)
