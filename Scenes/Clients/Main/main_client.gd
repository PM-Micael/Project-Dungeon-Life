extends Node2D
class_name MainClient

var game_initialized: bool = false

@onready var window_manager: WindowManager = get_node("WindowManager")
var wm_position: Vector2
var wm_size: Vector2

@onready var profile_window: ProfileWindow = $ProfileWindow
var pw_visible: bool = false
var pw_position: Vector2
var pw_size: Vector2

@onready var board_window: BoardWindow = get_node("RunManager/BoardWindow")
var bw_visible: bool = false
var bw_position: Vector2
var bw_size: Vector2

@onready var inventory_window: InventoryWindow = get_node("RunManager/InventoryWindow")
var iw_visible: bool = false
var iw_position: Vector2
var iw_size: Vector2

@onready var inner_sanctum_window: InnerSanctumWindow = get_node("InnerSanctumWindow")
var isw_visible: bool = false
var isw_position: Vector2
var isw_size: Vector2

@onready var dungeon_selection_window: DungeonSelectionWindow = get_node("DungeonSelectionWindow")
var dsw_visible: bool = false
var dsw_position: Vector2
var dsw_size: Vector2

var settings_window: SettingsWindow:
	get:
		return get_node("SettingsWindow")
var sw_visible: bool = false
var sw_position: Vector2
var sw_size: Vector2

@onready var run_manager: RunManager = get_node("RunManager")

var polygon_window: CollisionPolygon2D

# Inputs
var one_was_pressed := false

func _ready() -> void:
	_apply_settings()
	polygon_window = CollisionPolygon2D.new()
	get_window().mouse_passthrough_polygon = polygon_window.polygon
	await _initialize_game_data()

func _physics_process(_delta: float) -> void:
	if game_initialized:
		_check_update_polygon()
	
	var one_pressed = Input.is_key_pressed(Key.KEY_Q)
	if one_pressed and not one_was_pressed:
		window_manager._activate_menu_hotkey(0)
	one_was_pressed = one_pressed

func _apply_settings():
	var window = get_window()
	window.borderless = true

func _initialize_game_data():
	PlayerData.load_player_data()
	if not PlayerData.player_data_has_loaded:
		await PlayerData.player_data_loaded
	DungeonData.initialize_data()
	LocalData.load_local_data()
	game_initialized = true

func _check_update_polygon(): # Dont initialize them every time
	var new_wm_pos = Vector2(window_manager.position) - Vector2(20, 40)
	var new_wm_size = Vector2(window_manager.size) + Vector2(30, 50)
	
	var new_pw_visible: bool = profile_window.visible
	var new_pw_pos = Vector2(profile_window.position)
	var new_pw_size = Vector2(profile_window.size)
	
	var new_bw_visible = board_window.visible
	var new_bw_pos  = Vector2(board_window.position)
	var new_bw_size = Vector2(board_window.size)
	
	var new_iw_visible = inventory_window.visible
	var new_iw_pos  = Vector2(inventory_window.position)
	var new_iw_size = Vector2(inventory_window.size)
	
	var new_isw_visible = inner_sanctum_window.visible
	var new_isw_pos = Vector2(inner_sanctum_window.position)
	var new_isw_size = Vector2(inner_sanctum_window.size)
	
	var new_dsw_visible = dungeon_selection_window.visible
	var new_dsw_pos = Vector2(dungeon_selection_window.position)
	var new_dsw_size = Vector2(dungeon_selection_window.size)
	
	var new_sw_visible = settings_window.visible
	var new_sw_pos = Vector2(settings_window.position)
	var new_sw_size = Vector2(settings_window.size)
	
	if (
		wm_position != new_wm_pos or wm_size != new_wm_size or
		bw_position != new_bw_pos or bw_size != new_bw_size or bw_visible != new_bw_visible or
		iw_position != new_iw_pos or iw_size != new_iw_size or iw_visible != new_iw_visible or
		isw_position != new_isw_pos or isw_size != new_isw_size or isw_visible != new_isw_visible or
		dsw_position != new_dsw_pos or dsw_size != new_dsw_size or dsw_visible != new_dsw_visible or
		pw_position != new_pw_pos or pw_size != new_pw_size or pw_visible != new_pw_visible or
		sw_position != new_sw_pos or sw_size != new_sw_size or sw_visible != new_sw_visible 
		):

		var poly: Array[Vector2] = [Vector2(0, 0)]

		# Always include window manager
		poly.append_array([
			new_wm_pos,
			new_wm_pos + Vector2(new_wm_size.x, 0),
			new_wm_pos + new_wm_size,
			new_wm_pos + Vector2(0, new_wm_size.y),
			new_wm_pos,
			Vector2(0, 0),
		])
		
		if profile_window.visible:
			poly.append_array([
				new_pw_pos,
				new_pw_pos + Vector2(new_pw_size.x, 0),
				new_pw_pos + new_pw_size,
				new_pw_pos + Vector2(0, new_pw_size.y),
				new_pw_pos,
				Vector2(0, 0),
			])
		
		if dungeon_selection_window.visible:
			poly.append_array([
				new_dsw_pos,
				new_dsw_pos + Vector2(new_dsw_size.x, 0),
				new_dsw_pos + new_dsw_size,
				new_dsw_pos + Vector2(0, new_dsw_size.y),
				new_dsw_pos,
				Vector2(0, 0),
			])
		
		if inner_sanctum_window.visible:
			poly.append_array([
				new_isw_pos,
				new_isw_pos + Vector2(new_isw_size.x, 0),
				new_isw_pos + new_isw_size,
				new_isw_pos + Vector2(0, new_isw_size.y),
				new_isw_pos,
				Vector2(0, 0),
			])
		
		if settings_window.visible:
			poly.append_array([
				new_sw_pos,
				new_sw_pos + Vector2(new_sw_size.x, 0),
				new_sw_pos + new_sw_size,
				new_sw_pos + Vector2(0, new_sw_size.y),
				new_sw_pos,
				Vector2(0, 0),
			])
		
		# Only include board window if visible (not minimized)
		if board_window.visible:
			poly.append_array([
				new_bw_pos,
				new_bw_pos + Vector2(new_bw_size.x, 0),
				new_bw_pos + new_bw_size,
				new_bw_pos + Vector2(0, new_bw_size.y),
				new_bw_pos,
				Vector2(0, 0),
			])

		# Only include inventory window if visible (not minimized)
		if inventory_window.visible:
			poly.append_array([
				new_iw_pos,
				new_iw_pos + Vector2(new_iw_size.x, 0),
				new_iw_pos + new_iw_size,
				new_iw_pos + Vector2(0, new_iw_size.y),
				new_iw_pos,
				Vector2(0, 0),
			])

		polygon_window.polygon = PackedVector2Array(poly)
		get_window().mouse_passthrough_polygon = polygon_window.polygon
		
		pw_position = new_pw_pos
		pw_size = new_pw_size
		
		dsw_position = new_dsw_pos
		dsw_size = new_dsw_size
		
		isw_position = new_isw_pos
		isw_size = new_isw_size
		
		wm_position = new_wm_pos
		wm_size = new_wm_size
		
		bw_position = new_bw_pos
		bw_size = new_bw_size
		
		iw_position = new_iw_pos
		iw_size = new_iw_size
		
		sw_position = new_sw_pos
		sw_size = new_sw_size
