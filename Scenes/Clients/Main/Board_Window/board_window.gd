# Handle user interaction
extends Window
class_name BoardWindow

@onready var board_scene = preload("res://Scenes/Clients/board.tscn")

@onready var currently_selected_unit_entity_container: EntityContainer

var board: GameBoard
var map_tiles: MapTiles
var next_stage_button: Button
var exit_dungeon_button: Button
var start_stage_button: Button

func _ready() -> void:
	title = "Window Manager"
	size = Vector2i(800, 800)
	position = Vector2i(800, 800)
	unresizable = true
	#borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
