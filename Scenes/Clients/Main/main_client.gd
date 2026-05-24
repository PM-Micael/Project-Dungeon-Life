extends Node2D
class_name MainClient

var game_initialized: bool = false

@onready var window_manager: Window = get_node("WindowManager")
var wm_position: Vector2
var wm_size: Vector2

@onready var board_window: BoardWindow = get_node("RunManager/BoardWindow")
var bw_position: Vector2
var bw_size: Vector2

@onready var inventory_window: Window  = get_node("RunManager/InventoryWindow")
var iw_position: Vector2
var iw_size: Vector2

@onready var run_manager: RunManager = get_node("RunManager")

var polygon_window: CollisionPolygon2D 

func _ready() -> void:
	polygon_window = CollisionPolygon2D.new()
	get_window().mouse_passthrough_polygon = polygon_window.polygon
	await _initialize_game_data()
	
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
	var new_bw_pos  = Vector2(board_window.position)
	var new_bw_size = Vector2(board_window.size)
	var new_iw_pos  = Vector2(inventory_window.position)
	var new_iw_size = Vector2(inventory_window.size)
	if (
		wm_position != new_wm_pos or wm_size != new_wm_size or
		bw_position != new_bw_pos or bw_size != new_bw_size or
		iw_position != new_iw_pos or iw_size != new_iw_size
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
			new_iw_pos,
			new_iw_pos + Vector2(new_iw_size.x, 0),
			new_iw_pos + new_iw_size,
			new_iw_pos + Vector2(0, new_iw_size.y),
			new_iw_pos,
			Vector2(0, 0),
		])
		get_window().mouse_passthrough_polygon = polygon_window.polygon
		wm_position = new_wm_pos
		wm_size = new_wm_size
		bw_position = new_bw_pos
		bw_size = new_bw_size
		iw_position = new_iw_pos
		iw_size = new_iw_size
