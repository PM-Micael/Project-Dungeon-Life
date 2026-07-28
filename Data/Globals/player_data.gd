extends Node

signal player_data_loaded
signal player_data_saved
signal dungeon_run_ongoing_changed

var player_data_has_loaded: bool = false
var player_data_has_saved: bool = false

var player_id: String
var player_display_name: String = ""

var settings: Dictionary = {
	"auto_advance": false
}

var inner_sanctum: Dictionary = {
	"life": 1.0,
	"power": 1.0,
}
var inner_sanctum_essence_current = 0
var inner_sanctum_essence_total = 0

# Dungeon Data
var dungeon_id: String
var dungeon_room: int = 1
var dungeon_run_tier: int = 1
var dungeon_run_collected_esseence: int = 0
var current_zone: String

var dungeon_high_score: Dictionary = {
	"the_dungeon": {
		"tier_1":{
			"room": 1
		}
	},
}

var dungeon_layer_level: int: # Is this being used?
	get:
		return ceili(dungeon_room / 10.0)
var dungeon_enemy_multiplier: float: # Should be in dungeon data
	get:
		var scaling: float = 1 + (dungeon_room / 10.0)
		return scaling

var dungeon_zone_rolled_at_room: int = 1
var dungeon_run_ongoing: bool:
	set(value):
		dungeon_run_ongoing = value
		dungeon_run_ongoing_changed.emit(value, DungeonData.DUNGEONS.THE_DUNGEON)

var dungeon_run_ongoing_the_dungeon: bool:
	set(value):
		dungeon_run_ongoing_the_dungeon = value
		if player_data_has_loaded:
			dungeon_run_ongoing = value

var dungeon_team: Array[Unit]
var dungeon_team_formation_the_dungeon: Array[Dictionary] = [
	{
		"unit_name": "scratch",
		"starting_position": Vector2(350.0, 650.0),
		"weapon_id": "splinter",
		"weapon_star_level": 1
	},
	{
		"unit_name": "magnus",
		"starting_position": Vector2(350.0, 450.0),
		"weapon_id": "crag_chunk",
		"weapon_star_level": 1
	},
	{
		"unit_name": "paramander",
		"starting_position": Vector2(350.0, 550.0),
		"weapon_id": "heat_seeker",
		"weapon_star_level": 1
	},
]

var current_room_enemy_formation: Array = []

var dungeon_loot: Array[Dictionary] = []
var dungeon_loot_as_entities: Array[Entity] = []

func add_inner_sanctum_essence(amount: int):
	inner_sanctum_essence_total += amount
	inner_sanctum_essence_current += amount

func save_dungeon_team_as_formation(team_array: Array[Unit] = dungeon_team):
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
				weapon_star = wc.star_level
		
		var dict: Dictionary = {
			"unit_name": unit.id,
			"starting_position": unit.starting_position,
			"weapon_id": weapon_id,
			"weapon_star_level": weapon_star,
		}
		new_formation.append(dict)
	
	dungeon_team_formation_the_dungeon = new_formation

func reset_dungeon_run_data(dungeon: String):
	match dungeon:
		DungeonData.DUNGEONS.THE_DUNGEON:
			dungeon_room = 1
			dungeon_run_ongoing_the_dungeon = false
			dungeon_team = []
			dungeon_loot = []
			for entity in dungeon_loot_as_entities: # Why twice?
				entity.queue_free()
			dungeon_loot_as_entities = []
			dungeon_run_collected_esseence = 0
	save_player_data()

# Invenetory / Loot / Backback

func _initialize_loot_as_entities() -> void:
	dungeon_loot_as_entities.clear()
	for loot_entry in dungeon_loot:
		var item_id: String = loot_entry["item_id"]
		if not DungeonData.ITEM_REGISTRY.has(item_id):
			push_warning("PlayerData: No scene registered for item_id: " + item_id)
			continue
		var scene: PackedScene = load(DungeonData.ITEM_REGISTRY[item_id])
		var entity_instance: Entity = scene.instantiate()
		var wc: WeaponComponent = entity_instance.get_node_or_null("Components/WeaponComponent")
		if wc != null:
			wc.star_level = loot_entry["star_level"]
		dungeon_loot_as_entities.append(entity_instance)

func save_backpack_as_loot(backpack: Array[Entity] = dungeon_loot_as_entities):
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

func add_loot_to_inventory(loot: Array[Dictionary]) -> void:
	for loot_entry in loot:
		var item_id: String = loot_entry["item_id"]
		if not DungeonData.ITEM_REGISTRY.has(item_id):
			push_warning("DungeonData: No scene registered for item_id: " + item_id)
			continue
		var scene: PackedScene = load(DungeonData.ITEM_REGISTRY[item_id])
		var entity_instance: Entity = scene.instantiate()

		var wc: WeaponComponent = entity_instance.get_node_or_null("Components/WeaponComponent")
		if wc != null:
			wc.star_level = loot_entry["star_level"]

		PlayerData.dungeon_loot_as_entities.append(entity_instance)

# Database

func save_player_data():
	player_data_has_saved = false
	var data = {
		"id": player_id,
		"data": {
			"player_data": {
				"display_name": player_display_name
			},
			"dungeon_data": {
				"run_ongoing": dungeon_run_ongoing,
				"dungeon_id": dungeon_id,
				"room": dungeon_room,
				"tier": dungeon_run_tier,
				"collected_essence": dungeon_run_collected_esseence,
				"current_zone": current_zone,
				"team_formation": dungeon_team_formation_the_dungeon,
				"loot": dungeon_loot,
				"current_room_enemy_formation": current_room_enemy_formation
			},
			"dungeon_high_score": dungeon_high_score,
			"inner_sanctum": inner_sanctum,
			"inner_sanctum_essence_total": inner_sanctum_essence_total,
			"inner_sanctum_essence_current": inner_sanctum_essence_current
		}
	}
	
	var http = HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(func(result, code, headers, body):
		print("HTTP:", code)
		print(body.get_string_from_utf8())
		print()
	)
	
	var url = Auth.SUPABASE_URL + "/rest/v1/players"
	
	http.request(
		url,
		Auth.get_headers(),
		HTTPClient.METHOD_POST,
		JSON.stringify(data)
	)

	player_data_saved.emit()
	player_data_has_saved = true

func load_player_data():
	print("Id: " + player_id)

	var url = Database.SUPABASE_URL + "/rest/v1/players?id=eq." + player_id + "&select=data"

	var http = HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(func(_result, code, _headers, body):

		if code != 200:
			print("Load failed:", code)
			print(body.get_string_from_utf8())
			return

		var json = JSON.new()
		json.parse(body.get_string_from_utf8())

		var rows = json.data

		if rows.is_empty():
			print("Rows are empty")
			save_player_data()
			return

		var data = rows[0]["data"]

		player_display_name = data["player_data"]["display_name"]

		var dungeon = data["dungeon_data"]

		dungeon_run_ongoing = dungeon["run_ongoing"]
		dungeon_id = dungeon["dungeon_id"]
		dungeon_room = dungeon["room"]
		dungeon_run_tier = dungeon["tier"]
		dungeon_run_collected_esseence = dungeon["collected_essence"]
		current_zone = dungeon["current_zone"]

		inner_sanctum = data["inner_sanctum"]
		inner_sanctum_essence_total = data["inner_sanctum_essence_total"]
		inner_sanctum_essence_current = data["inner_sanctum_essence_current"]

		dungeon_high_score = data["dungeon_high_score"]

		# Team formation
		dungeon_team_formation_the_dungeon.clear()
		for unit in dungeon["team_formation"]:
			dungeon_team_formation_the_dungeon.append({
				"unit_name": unit["unit_name"],
				"weapon_id": unit["weapon_id"],
				"weapon_star_level": unit["weapon_star_level"],
				"starting_position": unit["starting_position"]
			})

		# Loot
		dungeon_loot.clear()

		for item in dungeon["loot"]:
			dungeon_loot.append(item)

		# Enemy formation
		current_room_enemy_formation.clear()

		for enemy in dungeon["current_room_enemy_formation"]:
			current_room_enemy_formation.append({
				"type": enemy["type"],
				"position": enemy["position"]
			})

		_initialize_loot_as_entities()

		player_data_has_loaded = true
		player_data_loaded.emit()

		print("Player data loaded successfully")
	)

	http.request(url, Auth.get_headers(), HTTPClient.METHOD_GET)
