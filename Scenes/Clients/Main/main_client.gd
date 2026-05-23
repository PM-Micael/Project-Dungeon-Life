extends Node2D

var window_manager: Window
var wm_position: Vector2
var wm_size: Vector2

var polygon_window_manager: CollisionPolygon2D 

func _ready() -> void:
	_set_window_manager()
	
	get_window().mouse_passthrough_polygon = polygon_window_manager.polygon

func _physics_process(_delta: float) -> void:
	_check_update_polygon()

func _check_update_polygon():
	var new_wm_pos  = Vector2(window_manager.position) - Vector2(20, 40)
	var new_wm_size = Vector2(window_manager.size) + Vector2(30, 50)
	if wm_position != new_wm_pos or wm_size != new_wm_size:
		print("Transform changed")
		polygon_window_manager.polygon = PackedVector2Array([
			Vector2(0, 0),
			new_wm_pos,
			new_wm_pos + Vector2(new_wm_size.x, 0),
			new_wm_pos + new_wm_size,
			new_wm_pos + Vector2(0, new_wm_size.y),
			new_wm_pos,
			Vector2(0, 0),
		])
		get_window().mouse_passthrough_polygon = polygon_window_manager.polygon
		wm_position = new_wm_pos
		wm_size = new_wm_size

func _set_window_manager():
	window_manager = Window.new()
	window_manager.set_script(load("res://Scenes/Clients/Main/Window_Manager/window_manager.gd"))
	add_child(window_manager)
	
	polygon_window_manager = CollisionPolygon2D.new()
