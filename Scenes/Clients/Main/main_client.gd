extends Node2D

var game_initialized: bool = false

var window_manager: Window
var wm_position: Vector2
var wm_size: Vector2

var board_window: Window
var bw_position: Vector2
var bw_size: Vector2

@onready var run_manager: RunManager = get_node("RunManager")

var polygon_window: CollisionPolygon2D 

func _ready() -> void:
	polygon_window = CollisionPolygon2D.new()
	get_window().mouse_passthrough_polygon = polygon_window.polygon
	await _initialize_game_data()
	
	_set_window_manager()
	_set_board_window()

func _physics_process(_delta: float) -> void:
	if game_initialized:
		_check_update_polygon()

func _initialize_game_data():
	PlayerData.load_player_data()
	await PlayerData.player_data_loaded
	DungeonData.initialize_data()
	game_initialized = true

func _check_update_polygon():
	var new_wm_pos  = Vector2(window_manager.position) - Vector2(20, 40)
	var new_wm_size = Vector2(window_manager.size) + Vector2(30, 50)
	var new_bw_pos  = Vector2(board_window.position) - Vector2(20, 40)
	var new_bw_size = Vector2(board_window.size) + Vector2(30, 50)
	if (
		wm_position != new_wm_pos or wm_size != new_wm_size or
		bw_position != new_bw_pos or bw_size != new_bw_size
		):
		print("Transform changed")
		polygon_window.polygon = PackedVector2Array([
			Vector2(0, 0),
			new_wm_pos,
			new_wm_pos + Vector2(new_wm_size.x, 0),
			new_wm_pos + new_wm_size,
			new_wm_pos + Vector2(0, new_wm_size.y),
			new_wm_pos,
			Vector2(0, 0),
			new_bw_pos,
			new_bw_pos + Vector2(new_bw_size.x, 0),
			new_bw_pos + new_bw_size,
			new_bw_pos + Vector2(0, new_bw_size.y),
			new_bw_pos,
			Vector2(0, 0),
		])
		get_window().mouse_passthrough_polygon = polygon_window.polygon
		wm_position = new_wm_pos
		wm_size = new_wm_size
		bw_position = new_bw_pos
		bw_size = new_bw_size

func _set_window_manager():
	window_manager = Window.new()
	window_manager.name = "WindowManager"
	window_manager.set_script(load("res://Scenes/Clients/Main/Window_Manager/window_manager.gd"))
	add_child(window_manager)

func _set_board_window():
	board_window = Window.new()
	board_window.name = "BoardWindow"
	board_window.set_script(load("res://Scenes/Clients/Main/Board_Window/board_window.gd"))
	run_manager.add_child(board_window)
