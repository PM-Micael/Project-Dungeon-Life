extends Node

signal player_data_loaded
signal player_data_saved
signal dungeon_run_ongoing_changed

var player_data_has_loaded: bool = false

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
	var url = "https://firestore.googleapis.com/v1/projects/project-dungeon-life/databases/(default)/documents/players/" + player_id
	
	# Serialize dungeon_team_formation
	var team_formation_array = []
	for unit in dungeon_team_formation_the_dungeon:
		team_formation_array.append({
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
	var loot_array = []
	for item in dungeon_loot:
		loot_array.append({ "mapValue": { "fields": {
			"item_id": { "stringValue": item["item_id"] },
			"star_level": { "integerValue": str(item["star_level"]) },
			"item_type": { "stringValue": item["item_type"] },
		}}})
	
	var enemy_formation_array: Array[Dictionary] = []
	for enemy in current_room_enemy_formation:
		enemy_formation_array.append({"mapValue": {"fields":{
			"type": {"stringValue": enemy["type"]},
			"pos_x": {"doubleValue": enemy["position"].x},
			"pos_y": {"doubleValue": enemy["position"].y}
		}}})
	
	var data = {
		"fields": {
			"player_data": {"mapValue": {"fields": {
				"display_name": { "stringValue": player_display_name },
			}}},
			"dungeon_data": { "mapValue": {"fields":{
				"current_room_enemy_formation": {"arrayValue": {"values": enemy_formation_array}},
				"run_ongoing": {"booleanValue": dungeon_run_ongoing},
				"dungeon_id": {"stringValue": dungeon_id},
				"room": {"integerValue": dungeon_room},
				"tier": {"integerValue": dungeon_run_tier},
				"collected_essence": {"integerValue": dungeon_run_collected_esseence},
				"current_zone": {"stringValue": current_zone},
				"team_formation": { "arrayValue": { "values": team_formation_array}},
				"loot": {"arrayValue": {"values": loot_array}}
			}}},
			"dungeon_high_score": {"mapValue": { "fields": {
				"the_dungeon": {"mapValue": {"fields": {
					"tier_1": {"mapValue": {"fields": {
						"room": {"integerValue": str(dungeon_high_score["the_dungeon"]["tier_1"]["room"])}
					}}}
				}}}
			}}},
			"inner_sanctum_essence_total": { "integerValue": str(inner_sanctum_essence_total) },
			"inner_sanctum_essence_current": { "integerValue": str(inner_sanctum_essence_current) },
			"inner_sanctum": { "mapValue": { "fields": {
				"life": {"doubleValue": inner_sanctum["life"]},
				"power": {"doubleValue": inner_sanctum["power"]},
			}}},
		}
	}
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_result, code, headers, _body):
		print("Save result - HTTP code: ", code)
	)
	
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)
	player_data_saved.emit()

func load_player_data():	
	var id_file_path = "res://player_id.txt"
	var file = FileAccess.open(id_file_path, FileAccess.READ)
	if file:
		var stored_id = file.get_as_text().strip_edges()
		file.close()
		if stored_id != "":
			player_id = stored_id
		else:
			player_id = _generate_guid()
			_write_player_id(player_id)
	else:
		player_id = _generate_guid()
		_write_player_id(player_id)
	# ---------------------------
	
	var url = "https://firestore.googleapis.com/v1/projects/project-dungeon-life/databases/(default)/documents/players/" + player_id
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_result, code, headers, body):
		if code == 404:
			save_player_data()
			await get_tree().create_timer(0.5).timeout
			load_player_data()
			return
		if code != 200:
			print("Load failed - HTTP code: ", code)
			return
		
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var fields = json.get_data()["fields"]
		var dungeon_fields = fields["dungeon_data"]["mapValue"]["fields"]
		
		# Basic fields
		player_display_name = fields["player_data"]["mapValue"]["fields"]["display_name"]["stringValue"]
		dungeon_run_tier = int(dungeon_fields["tier"]["integerValue"])
		current_zone = dungeon_fields["current_zone"]["stringValue"]
		inner_sanctum_essence_total = int(fields["inner_sanctum_essence_total"]["integerValue"])
		inner_sanctum_essence_current = int(fields["inner_sanctum_essence_current"]["integerValue"])
		
		# Inner sanctum
		var sanctum_fields = fields["inner_sanctum"]["mapValue"]["fields"]
		inner_sanctum["life"] = float(sanctum_fields["life"]["doubleValue"])
		inner_sanctum["power"] = float(sanctum_fields["power"]["doubleValue"])
		
		# Dungeon team formation
		if fields.has("dungeon_high_score"):
			var high_score = fields["dungeon_high_score"]["mapValue"]["fields"]
			dungeon_high_score["the_dungeon"]["tier_1"]["room"] = int(
			high_score["the_dungeon"]["mapValue"]["fields"]
				["tier_1"]["mapValue"]["fields"]
				["room"]["integerValue"]
			)
		else:
			print("Fields dungeon_high_score doesn't exist")
		dungeon_run_ongoing = dungeon_fields["run_ongoing"]["booleanValue"]
		if dungeon_run_ongoing:
			dungeon_room = int(dungeon_fields["room"]["integerValue"])
			dungeon_team_formation_the_dungeon.clear()
			var team_formation_values = dungeon_fields["team_formation"]["arrayValue"].get("values", [])
			for entry in team_formation_values:
				var f = entry["mapValue"]["fields"]
				dungeon_team_formation_the_dungeon.append({
					"unit_name": f["unit_name"]["stringValue"],
					"weapon_id": f["weapon_id"]["stringValue"],
					"weapon_star_level": int(f["weapon_star_level"]["integerValue"]),
					"starting_position": Vector2(
						float(f["pos_x"]["doubleValue"]),
						float(f["pos_y"]["doubleValue"])
					)
				})
			current_room_enemy_formation.clear()
			if dungeon_fields.has("current_room_enemy_formation"):
				var enemy_formation_values = dungeon_fields["current_room_enemy_formation"]["arrayValue"].get("values",[])
				for entry in enemy_formation_values:
					var e = entry["mapValue"]["fields"]
					current_room_enemy_formation.append({
						"type": e["type"]["stringValue"],
						"position": Vector2(
							float(e["pos_x"]["doubleValue"]),
							float(e["pos_y"]["doubleValue"]),
						)
					})
				
			# Dungeon loot
			dungeon_loot.clear()
			var loot_values = dungeon_fields["loot"]["arrayValue"].get("values", [])
			for entry in loot_values:
				var l = entry["mapValue"]["fields"]
				dungeon_loot.append({
					"item_id": l["item_id"]["stringValue"],
					"star_level": int(l["star_level"]["integerValue"]),
					"item_type": l["item_type"]["stringValue"],
				})
			dungeon_run_collected_esseence = int(dungeon_fields["collected_essence"]["integerValue"])
		
		print("Player data loaded successfully")
		_initialize_loot_as_entities()
		player_data_has_loaded = true
		player_data_loaded.emit()
	)
	
	http.request(url, [], HTTPClient.METHOD_GET, "")

func _generate_guid() -> String:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var b = func(_n): return "%02x" % (rng.randi() % 256)
	return (
		b.call(0)+b.call(1)+b.call(2)+b.call(3) + "-" +
		b.call(4)+b.call(5) + "-" +
		b.call(6)+b.call(7) + "-" +
		b.call(8)+b.call(9) + "-" +
		b.call(10)+b.call(11)+b.call(12)+b.call(13)+b.call(14)+b.call(15)
	)

func _write_player_id(id: String) -> void:
	var file = FileAccess.open("res://player_id.txt", FileAccess.WRITE)
	if file:
		file.store_string(id)
		file.close()
	else:
		push_warning("PlayerData: Could not write player_id.txt")
