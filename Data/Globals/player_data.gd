extends Node

var player_id: String = ""
var display_name: String = "" 

var total_inner_sanctum_essence = 0
var current_inner_sanctum_essence = 12 
var inner_sanctum: Dictionary = {
	"life": 1.5,
	"power": 1.0,
}

# Progression data
var dungeon_tier: int = 1
var dungeon_room: int = 5

var dungeon_team_max_size = 4
var dungeon_team: Array[Unit]
var dungeon_team_formation: Array[Dictionary] = [
	{
		"unit_name": "scratch",
		"starting_position": Vector2(350.0, 650.0),
		"weapon_id": "splinter"
	},
	{
		"unit_name": "zac",
		"starting_position": Vector2(350.0, 450.0),
		"weapon_id": "rumble_gloves"
	},
	{
		"unit_name": "walking_hive",
		"starting_position": Vector2(350.0, 550.0),
		"weapon_id": "cursed_lantern"
	},
]

var dungeon_loot: Array[Dictionary] = [
	{
		"item_id": "burst_staff",
		"star_level": 1,
		"item_type": "weapon"
	},
]

func add_inner_sanctum_essence(amount: int):
	total_inner_sanctum_essence += amount
	current_inner_sanctum_essence += amount

func save_dungeon_team_as_formation(team_array: Array[Unit] = dungeon_team):
	var new_formation: Array[Dictionary] = []
	
	for unit in team_array:
		var weapon_id: String = ""
		var weapon_slot = unit.get_node_or_null("Components/WeaponSlotComponent")
		if weapon_slot != null and weapon_slot.get_child_count() > 0:
			weapon_id = weapon_slot.get_child(0).id
		
		var dict: Dictionary = {
			"unit_name": unit.id,
			"starting_position": unit.starting_position,
			"weapon_id": weapon_id
		}
		new_formation.append(dict)
	
	dungeon_team_formation = new_formation

func save_backpack_as_loot(backpack: Array[Entity] = DungeonData.backpack_contents_as_entities) -> void:
	var new_loot: Array[Dictionary] = []
	for entity in backpack:
		new_loot.append({
			"item_id": entity.id,
			"star_level": entity.weapon_component.star_level,
		})
	dungeon_loot = new_loot
