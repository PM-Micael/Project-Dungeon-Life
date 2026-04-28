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
