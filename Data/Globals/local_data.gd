extends Node

var board: GameBoard
var ui: Node2D

var current_board_layout_id: int:
	set(value):
		current_board_layout_id = value
		_set_layout()
var current_inventory_layout_id: int:
	set(value):
		current_inventory_layout_id = value
		_set_layout()

func initialize_data(_ui: Node2D, _board: GameBoard = board):
	board = _board
	ui = _ui
	current_board_layout_id = 1
	current_inventory_layout_id = 1

func _set_layout():
	var layout_id: String = (str(0) + str(current_inventory_layout_id) + str(current_board_layout_id))
	
	var window = get_window()
	window.mouse_passthrough_polygon = polygon_shape["setups"][layout_id]
	var board_position: Vector2 = polygon_shape["position_setup"][layout_id]["board"]
	var invencory_position: Vector2 = polygon_shape["position_setup"][layout_id]["inventory"]
	
	# Placeholder solution
	if current_board_layout_id == 1:
		board.scale = Vector2(0.4, 0.4)
	elif current_board_layout_id == 2:
		board.scale = Vector2(1, 1)
	
	if current_inventory_layout_id == 1:
		ui.scale = Vector2(0.4, 0.4)
	elif current_inventory_layout_id == 2:
		ui.scale = Vector2(1, 1)
	
	board.position = Vector2(board_position)
	ui.position = Vector2(invencory_position)

var polygon_shape: Dictionary = {
	"setups": 
	{
		"001": 	
		[
		Vector2(1920.0, 1080.0),
		Vector2(1600.0, 1080.0),
		Vector2(1600.0, 760.0),
		Vector2(1920.0, 760.0),
		],
		"010": [
		Vector2(1920.0, 1080.0),
		Vector2(1120.0, 1080.0),
		Vector2(1120.0, 280.0),
		Vector2(1920.0, 280.0),
		],
		"002": [
		Vector2(1920.0, 1080.0),
		Vector2(1120.0, 1080.0),
		Vector2(1120.0, 280.0),
		Vector2(1920.0, 280.0),
		],
		"011": [
		Vector2(0.0, 0.0),
		Vector2(1920.0, 0.0),
		Vector2(1920.0, 1080.0),
		Vector2(1280.0, 1080.0),
		Vector2(1280.0, 760.0),
		Vector2(1920.0, 760.0),
		Vector2(1919.9, 0.1),
		Vector2(1090.0, 0.1),
		Vector2(1090.0, 40.0),
		Vector2(910.0, 40.0),
		Vector2(910.0, 1.0),
		],
		"012": [
		Vector2(0.0, 0.0),
		Vector2(1920.0, 0.0),
		Vector2(1920.0, 1080.0),
		Vector2(800.0, 1080.0),
		Vector2(800.0, 760.0),
		Vector2(1120.9999, 760.0),
		Vector2(1120.9999, 280.0),
		Vector2(1919.0, 280.0),
		Vector2(1919.0, 0.1),
		Vector2(1090.0, 0.1),
		Vector2(1090.0, 40.0),
		Vector2(910.0, 40.0),
		Vector2(910.0, 1.0),
		],
		"021": [
		Vector2(0.0, 0.0),
		Vector2(1920.0, 0.0),
		Vector2(1920.0, 1080.0),
		Vector2(800.0, 1080.0),
		Vector2(800.0, 280.0),
		Vector2(1600.0, 280.0),
		Vector2(1600.0, 760.0),
		Vector2(1919.9, 760.0),
		Vector2(1919.9, 0.1),
		Vector2(1090.0, 0.1),
		Vector2(1090.0, 40),
		Vector2(910.0, 40),
		Vector2(910.0, 1.0),
		],
		"022": [
		Vector2(0.0, 0.0),
		Vector2(1920.0, 0.0),
		Vector2(1920.0, 1080.0),
		Vector2(320.0, 1080.0),
		Vector2(320.0, 280.0),
		Vector2(1919.9999, 280.0),
		Vector2(1919.9999, 0.1),
		Vector2(1090.0, 0.1),
		Vector2(1090.0, 40.0),
		Vector2(910.0, 40.0),
		],
	},
	"position_setup":
	{
		"001": {
			"board": Vector2(1600.0, 760.0),
			"inventory": Vector2(0, 0)
		},
		"002": {
			"board": Vector2(1120.0, 280.0),
			"inventory": Vector2(0, 0)
		},
		"011": {
			"board": Vector2(1600.0, 760.0),
			"inventory": Vector2(1280.0, 950.0)
		},
		"012": {
			"board": Vector2(1120.0, 280.0),
			"inventory": Vector2(800.0, 950.0)
		},
		"021": {
			"board": Vector2(1600.0, 760.0),
			"inventory": Vector2(800.0, 755.0)
		},
		"022": {
			"board": Vector2(1120.0, 280.0),
			"inventory": Vector2(320.0, 755.0)
		},
	}
}
