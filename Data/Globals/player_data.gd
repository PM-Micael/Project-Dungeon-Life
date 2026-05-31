extends Node

signal player_data_loaded
signal dungeon_run_ongoing_changed

var player_data_has_loaded: bool = false

var player_id: String = "dare_mane"
var player_display_name: String = "DareMane"

var settings: Dictionary = {
	"auto_advance": false
}

var inner_sanctum: Dictionary = {
	"life": 1.0,
	"power": 1.0,
}
var inner_sanctum_essence_current = 0
var inner_sanctum_essence_total = 0

# Dungeons
var dungeon_run_tier: int = 1
var dungeon_room: int = 1
var dungeon_layer_level: int: # Is this being used?
	get:
		return ceili(dungeon_layer_level / 10.0)
var dungeon_enemy_multiplier: float: # Should be in dungeon data
	get:
		var scaling: float = 1 + (dungeon_layer_level / 10.0)
		return scaling

var dungeon_run_ongoing: bool:
	set(value):
		dungeon_run_ongoing = value
		if dungeon_run_ongoing_putrid_layers:
			dungeon_run_ongoing_changed.emit(value, DungeonData.Zone.PUTRID_LAYERS)
		elif dungeon_run_ongoing_scorched_grounds:
			dungeon_run_ongoing_changed.emit(value, DungeonData.Zone.SCORCHED_GROUNDS)

var dungeon_run_ongoing_putrid_layers: bool:
	set(value):
		dungeon_run_ongoing_putrid_layers = value
		if player_data_has_loaded:
			dungeon_run_ongoing = value

var dungeon_run_ongoing_scorched_grounds: bool:
	set(value):
		dungeon_run_ongoing_scorched_grounds = value
		if player_data_has_loaded:
			dungeon_run_ongoing = value

var dungeon_team_max_size_ = 4
var dungeon_team_putrid_layers: Array[Unit]
var dungeon_team_formation_putrid_layers: Array[Dictionary] = [
	{
		"unit_name": "scratch",
		"starting_position": Vector2(350.0, 650.0),
		"weapon_id": "splinter",
		"weapon_star_level": 1
	},
	{
		"unit_name": "zac",
		"starting_position": Vector2(350.0, 450.0),
		"weapon_id": "rumble_gloves",
		"weapon_star_level": 1
	},
	{
		"unit_name": "walking_hive",
		"starting_position": Vector2(350.0, 550.0),
		"weapon_id": "cursed_lantern",
		"weapon_star_level": 1
	},
]
var dungeon_team_formation_scorched_grounds: Array[Dictionary] = [
	{
		"unit_name": "scratch",
		"starting_position": Vector2(350.0, 650.0),
		"weapon_id": "splinter",
		"weapon_star_level": 1
	},
	{
		"unit_name": "zac",
		"starting_position": Vector2(350.0, 450.0),
		"weapon_id": "rumble_gloves",
		"weapon_star_level": 1
	},
]

var dungeon_loot: Array[Dictionary] = []
var dungeon_loot_as_entities: Array[Entity] = []

func add_inner_sanctum_essence(amount: int):
	inner_sanctum_essence_total += amount
	inner_sanctum_essence_current += amount

func save_dungeon_team_as_formation(team_array: Array[Unit] = dungeon_team_putrid_layers):
	var new_formation: Array[Dictionary] = []
	
	for unit in team_array:
		var weapon_id: String = ""
		var weapon_star: int = 1  # ← add this
		var weapon_slot = unit.get_node_or_null("Components/WeaponSlotComponent")
		if weapon_slot != null and weapon_slot.get_child_count() > 0:
			var weapon = weapon_slot.get_child(0)
			weapon_id = weapon.id
			var wc: WeaponComponent = weapon.get_node_or_null("Components/WeaponComponent")
			if wc != null:
				weapon_star = wc.star_level  # ← add this
		
		var dict: Dictionary = {
			"unit_name": unit.id,
			"starting_position": unit.starting_position,
			"weapon_id": weapon_id,
			"weapon_star_level": weapon_star,  # ← add this
		}
		new_formation.append(dict)
	
	dungeon_team_formation_putrid_layers = new_formation

func save_backpack_as_loot(backpack: Array[Entity] = DungeonData.backpack_contents_as_entities) -> void:
	var new_loot: Array[Dictionary] = []
	for entity in backpack:
		var star: int = 1
		var wc: WeaponComponent = entity.get_node_or_null("Components/WeaponComponent")
		if wc != null:
			star = wc.star_level
		new_loot.append({
			"item_id": entity.id,
			"star_level": star,
			"item_type": "weapon",
		})
	dungeon_loot = new_loot

func reset_dungeon_run_data(dungeon: String):
	match dungeon:
		DungeonData.Zone.PUTRID_LAYERS:
			dungeon_room = 1
			dungeon_run_ongoing_putrid_layers = false
			dungeon_team_putrid_layers = []
			dungeon_loot = []
			dungeon_loot_as_entities = []
			DungeonData.reset_backpack()
	
	save_player_data()

# Database

func save_player_data(): 
	var url = "https://firestore.googleapis.com/v1/projects/project-dungeon-life/databases/(default)/documents/players/" + player_id
	
	# Serialize dungeon_team_formation
	var formation_array_putrid_layers = []
	for unit in dungeon_team_formation_putrid_layers:
		formation_array_putrid_layers.append({
			"mapValue": {
				"fields": {
					"unit_name": { "stringValue": unit["unit_name"] },
					"weapon_id": { "stringValue": unit["weapon_id"] },
					"weapon_star_level": { "integerValue": str(unit.get("weapon_star_level", 1)) },
					"pos_x": { "doubleValue": unit["starting_position"].x },
					"pos_y": { "doubleValue": unit["starting_position"].y },
				}
			}
		})
	
	# Serialize dungeon_loot
	var loot_array_putrid_layers = []
	for item in dungeon_loot:
		loot_array_putrid_layers.append({
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
			"player_display_name": { "stringValue": player_display_name },
			"dungeon_run_ongoing": {"booleanValue": dungeon_run_ongoing},
			"dungeon_run_ongoing_putrid_layers": {"booleanValue": dungeon_run_ongoing_putrid_layers },
			"dungeon_run_ongoing_scorched_grounds": {"booleanValue": dungeon_run_ongoing_scorched_grounds},
			"dungeon_run_tier": { "integerValue": str(dungeon_run_tier) },
			"dungeon_room": { "integerValue": str(dungeon_room) },
			"inner_sanctum_essence_total": { "integerValue": str(inner_sanctum_essence_total) },
			"inner_sanctum_essence_current": { "integerValue": str(inner_sanctum_essence_current) },
			"inner_sanctum": {
				"mapValue": {
					"fields": {
						"life": { "doubleValue": inner_sanctum["life"] },
						"power": { "doubleValue": inner_sanctum["power"] },
					}
				}
			},
			"dungeon_team_formation_putrid_layers": {
				"arrayValue": { "values": formation_array_putrid_layers }
			},
			"dungeon_loot": {
				"arrayValue": { "values": loot_array_putrid_layers }
			},
		}
	}
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result, code, headers, body):
		print("Save result - HTTP code: ", code)
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
			return
		
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var fields = json.get_data()["fields"]
		
		# Basic fields
		player_display_name = fields["player_display_name"]["stringValue"]
		dungeon_run_tier = int(fields["dungeon_run_tier"]["integerValue"])
		inner_sanctum_essence_total = int(fields["inner_sanctum_essence_total"]["integerValue"])
		inner_sanctum_essence_current = int(fields["inner_sanctum_essence_current"]["integerValue"])
		
		# Inner sanctum
		var sanctum_fields = fields["inner_sanctum"]["mapValue"]["fields"]
		inner_sanctum["life"] = float(sanctum_fields["life"]["doubleValue"])
		inner_sanctum["power"] = float(sanctum_fields["power"]["doubleValue"])
		
		# Dungeon team formation
		dungeon_run_ongoing_putrid_layers = fields["dungeon_run_ongoing_putrid_layers"]["booleanValue"]
		dungeon_run_ongoing_scorched_grounds = fields["dungeon_run_ongoing_scorched_grounds"]["booleanValue"]
		dungeon_run_ongoing = fields["dungeon_run_ongoing"]["booleanValue"]
		if dungeon_run_ongoing:
			dungeon_room = int(fields["dungeon_room"]["integerValue"])
			if dungeon_run_ongoing_putrid_layers:
				dungeon_team_formation_putrid_layers.clear()
				var formation_values = fields["dungeon_team_formation_putrid_layers"]["arrayValue"].get("values", [])
				for entry in formation_values:
					var f = entry["mapValue"]["fields"]
					dungeon_team_formation_putrid_layers.append({
						"unit_name": f["unit_name"]["stringValue"],
						"weapon_id": f["weapon_id"]["stringValue"],
						"weapon_star_level": int(f["weapon_star_level"]["integerValue"]),
						"starting_position": Vector2(
							float(f["pos_x"]["doubleValue"]),
							float(f["pos_y"]["doubleValue"])
						)
					})
			elif dungeon_run_ongoing_scorched_grounds:
				dungeon_team_formation_scorched_grounds.clear()
				var formation_values = fields["dungeon_team_formation_scorched_grounds"]["arrayValue"].get("values", [])
				for entry in formation_values:
					var f = entry["mapValue"]["fields"]
					dungeon_team_formation_scorched_grounds.append({
						"unit_name": f["unit_name"]["stringValue"],
						"weapon_id": f["weapon_id"]["stringValue"],
						"weapon_star_level": int(f["weapon_star_level"]["integerValue"]),
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
		player_data_has_loaded = true
		player_data_loaded.emit()
	)
	
	http.request(url, [], HTTPClient.METHOD_GET, "")
