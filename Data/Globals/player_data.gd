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
	"board_scale": 
	{
		1: [
		Vector2(1120.0, 280.0),
		Vector2(1120.0, 1080.0),
		Vector2(1920.0, 1080.0),
		Vector2(1920.0, 280.0),
		],
		0.5: 	
		[
		Vector2(1520.0, 680.0),
		Vector2(1520.0, 1080.0),
		Vector2(1920.0, 1080.0),
		Vector2(1920.0, 680.0),
		]
	},
	"board_position_based_on_scale":
	{
		0.5: Vector2(760.0, 340.0),
		1: Vector2(560.0, 140.0),
	}
}
