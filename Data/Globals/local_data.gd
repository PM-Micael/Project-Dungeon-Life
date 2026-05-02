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

func initialize_data(_board: GameBoard, _ui: Node2D):
	board = _board
	ui = _ui
	current_board_layout_id = 1
	current_inventory_layout_id = 1

func _set_layout():
	var layout_id: String = (str(0) + str(current_inventory_layout_id) + str(current_board_layout_id))
	
	var window = get_window()
	window.mouse_passthrough_polygon = PlayerData.polygon_shape["setups"][layout_id]
	var board_position: Vector2 = PlayerData.polygon_shape["position_setup"][layout_id]["board"]
	var invencory_position: Vector2 = PlayerData.polygon_shape["position_setup"][layout_id]["inventory"]
	
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
