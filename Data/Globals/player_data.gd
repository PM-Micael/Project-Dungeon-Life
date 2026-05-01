extends Node

# --- Auth (future Firebase) ---
var player_id: String = ""
var display_name: String = ""

# --- Persistent State ---
var inner_sanctum: Dictionary = {
	"life": 2,
	"power": 1
}

# --- Stage Snapshots ---
# { "unit_scene": String, "weapon_scene": String, "accessories": Array[String] }
var dungeon_team_snapshot: Array[Dictionary] = []

# { "unit_scene": String, "position": { "x": float, "y": float } }
var dungeon_enemy_snapshot: Array[Dictionary] = []

# --- Future Firebase hooks ---
# func load_from_json(data: Dictionary) -> void: ...
# func to_json() -> Dictionary: ...

var polygon_shape: Dictionary = {
	"setups": 
	{
		001: 	
		[
		Vector2(1920.0, 1080.0),
		Vector2(1600.0, 1080.0),
		Vector2(1600.0, 760.0),
		Vector2(1920.0, 760.0),
		],
		010: [
		Vector2(1920.0, 1080.0),
		Vector2(1120.0, 1080.0),
		Vector2(1120.0, 280.0),
		Vector2(1920.0, 280.0),
		],
		002: [
		Vector2(1920.0, 1080.0),
		Vector2(1120.0, 1080.0),
		Vector2(1120.0, 280.0),
		Vector2(1920.0, 280.0),
		],
		011: [
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
		012: [
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
		021: [
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
		022: [
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
	"board_position_setup":
	{
		001: Vector2(1720.0, 880.0),
		002: Vector2(1520.0, 680.0),
		011: Vector2(1760.0, 920.0),
		012: Vector2(1520.0, 680.0),
		021: Vector2(1760.0, 920.0),
		022: Vector2(1520.0, 680.0),
	}
}
