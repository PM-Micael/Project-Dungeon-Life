extends Node

# --- Auth (future Firebase) ---
var player_id: String = ""
var display_name: String = ""

# --- Persistent State ---
var inner_sanctum: Dictionary = {
	"life": 2,
	"power": 1
}

var dungeon_team_max_size = 4
var dungeon_team: Array[Unit]
var dngeon_team_formation: Array[Dictionary] = [
	{
		"unit_name": "petamer",
		"starting_position": Vector2(50.0, 750.0),
		"weapon_id": ""
	},
	{
		"unit_name": "soulbound",
		"starting_position": Vector2(150.0, 750.0),
		"weapon_id": ""
	},
	{
		"unit_name": "orbath",
		"starting_position": Vector2(250.0, 750.0),
		"weapon_id": ""
	},
	{
		"unit_name": "zac",
		"starting_position": Vector2(350.0, 750.0),
		"weapon_id": ""
	},
]

func save_dungeon_team_as_formation(team: Array[Unit]):
	var loop_itteration: int = 0
	for unit in team:
		dngeon_team_formation[loop_itteration]["unit_name"] = team[loop_itteration].name
		dngeon_team_formation[loop_itteration]["starting_position"] = team[loop_itteration].starting_position

func get_dungeon_team() -> Array[Unit]:
	return []
