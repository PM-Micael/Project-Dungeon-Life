extends Node

var player_id: String = ""
var display_name: String = ""

var inner_sanctum: Dictionary = {
	"life": 2,
	"power": 1
}

# Progression data
var dungeon_tier: int = 1
var dungeon_wave: int = 1

var dungeon_team_max_size = 4
var dungeon_team: Array[Unit]
var dungeon_team_formation: Array[Dictionary] = [
	{
		"unit_name": "petamer",
		"starting_position": Vector2(150.0, 650.0),
		"weapon_name": ""
	},
	{
		"unit_name": "soulbound",
		"starting_position": Vector2(250.0, 650.0),
		"weapon_name": "burst_staff"
	},
	{
		"unit_name": "orbath",
		"starting_position": Vector2(350.0, 650.0),
		"weapon_name": "burst_staff"
	},
	{
		"unit_name": "zac",
		"starting_position": Vector2(450.0, 650.0),
		"weapon_name": ""
	},
]

func save_dungeon_team_as_formation():
	var new_formation: Array[Dictionary] = []
	
	for unit in dungeon_team:
		var weaepon_name: String = ""
		var weapon_slot = unit.get_node_or_null("Components/WeaponSlotComponent")
		if weapon_slot != null and weapon_slot.get_child_count() > 0:
			weaepon_name = weapon_slot.get_child(0).name
		
		var dict: Dictionary = {
			"unit_name": unit.name,
			"starting_position": unit.starting_position,
			"weapon_id": weaepon_name
		}
		new_formation.append(dict)
	
	dungeon_team_formation = new_formation

func get_dungeon_team() -> Array[Unit]:
	return []
