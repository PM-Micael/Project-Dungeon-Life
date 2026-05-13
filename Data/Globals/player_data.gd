extends Node

signal player_data_loaded

var player_id: String = "dare_mane"
var display_name: String = "DareMane"

var total_inner_sanctum_essence = 0
var current_inner_sanctum_essence = 0
var inner_sanctum: Dictionary = {
	"life": 1.0,
	"power": 1.0,
}

# Progression data
var dungeon_tier: int = 1
var dungeon_room: int = 1

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

# Database

func save_player_data():
	var url = "https://firestore.googleapis.com/v1/projects/project-dungeon-life/databases/(default)/documents/players/" + player_id
	
	# Serialize dungeon_team_formation
	var formation_array = []
	for unit in dungeon_team_formation:
		formation_array.append({
			"mapValue": {
				"fields": {
					"unit_name": { "stringValue": unit["unit_name"] },
					"weapon_id": { "stringValue": unit["weapon_id"] },
					"pos_x": { "doubleValue": unit["starting_position"].x },
					"pos_y": { "doubleValue": unit["starting_position"].y },
				}
			}
		})
	
	# Serialize dungeon_loot
	var loot_array = []
	for item in dungeon_loot:
		loot_array.append({
			"mapValue": {
				"fields": {
					"item_id": { "stringValue": item["item_id"] },
					"star_level": { "integerValue": str(item["star_level"]) },
					"item_type": { "stringValue": item["item_type"] },
				}
			}
		})
	
	var data = {
		"fields": {
			"display_name": { "stringValue": display_name },
			"dungeon_tier": { "integerValue": str(dungeon_tier) },
			"dungeon_room": { "integerValue": str(dungeon_room) },
			"total_inner_sanctum_essence": { "integerValue": str(total_inner_sanctum_essence) },
			"current_inner_sanctum_essence": { "integerValue": str(current_inner_sanctum_essence) },
			"inner_sanctum": {
				"mapValue": {
					"fields": {
						"life": { "doubleValue": inner_sanctum["life"] },
						"power": { "doubleValue": inner_sanctum["power"] },
					}
				}
			},
			"dungeon_team_formation": {
				"arrayValue": { "values": formation_array }
			},
			"dungeon_loot": {
				"arrayValue": { "values": loot_array }
			},
		}
	}
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result, code, headers, body):
		print("Save result - HTTP code: ", code)
		print("Body: ", body.get_string_from_utf8())
	)
	
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)

func load_player_data():
	var url = "https://firestore.googleapis.com/v1/projects/project-dungeon-life/databases/(default)/documents/players/" + player_id
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result, code, headers, body):
		if code != 200:
			print("Load failed - HTTP code: ", code)
			print("Body: ", body.get_string_from_utf8())
			return
		
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var fields = json.get_data()["fields"]
		
		# Basic fields
		display_name = fields["display_name"]["stringValue"]
		dungeon_tier = int(fields["dungeon_tier"]["integerValue"])
		dungeon_room = int(fields["dungeon_room"]["integerValue"])
		total_inner_sanctum_essence = int(fields["total_inner_sanctum_essence"]["integerValue"])
		current_inner_sanctum_essence = int(fields["current_inner_sanctum_essence"]["integerValue"])
		
		# Inner sanctum
		var sanctum_fields = fields["inner_sanctum"]["mapValue"]["fields"]
		inner_sanctum["life"] = float(sanctum_fields["life"]["doubleValue"])
		inner_sanctum["power"] = float(sanctum_fields["power"]["doubleValue"])
		
		# Dungeon team formation
		dungeon_team_formation.clear()
		var formation_values = fields["dungeon_team_formation"]["arrayValue"].get("values", [])
		for entry in formation_values:
			var f = entry["mapValue"]["fields"]
			dungeon_team_formation.append({
				"unit_name": f["unit_name"]["stringValue"],
				"weapon_id": f["weapon_id"]["stringValue"],
				"starting_position": Vector2(
					float(f["pos_x"]["doubleValue"]),
					float(f["pos_y"]["doubleValue"])
				)
			})
		
		# Dungeon loot
		dungeon_loot.clear()
		var loot_values = fields["dungeon_loot"]["arrayValue"].get("values", [])
		for entry in loot_values:
			var l = entry["mapValue"]["fields"]
			dungeon_loot.append({
				"item_id": l["item_id"]["stringValue"],
				"star_level": int(l["star_level"]["integerValue"]),
				"item_type": l["item_type"]["stringValue"],
			})
		
		print("Player data loaded successfully")
		player_data_loaded.emit()
	)
	
	http.request(url, [], HTTPClient.METHOD_GET, "")
