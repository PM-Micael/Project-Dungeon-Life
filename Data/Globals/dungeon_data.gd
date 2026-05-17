extends Node

signal dungeon_data_loaded

const Zone = {
	PUTRID_LAYERS = "putrid_layers"
}

const EnemyType = {
	FLESH_GOUL = "flesh_goul",
	FLESH_HULK = "flesh_hulk",
	FLESH_TENDRILl = "flesh_tendrill",
	FLESH_BRUSER = "flesh_bruser",
	PUTRID_ABOMINATION = "putrid_abomination",
	SKELETON = "skeleton",
}

const ITEM_REGISTRY: Dictionary = {
	"burst_staff": "res://Scenes/Weapons/burst_staff.tscn",
	"clobber_club": "res://Scenes/Weapons/clobber_club.tscn",
	"splinter": "res://Scenes/Weapons/splinter/splinter.tscn",
	"cursed_lantern": "res://Scenes/Weapons/cursed_lantern/cursed_lantern.tscn",
}

# Units
var dungeon_team: Array[Entity]
var available_units_as_entities: Array[Entity]
var _available_units_as_packed_scenes: Array[PackedScene] = [
	preload("res://Scenes/Units/goblin.tscn"),
	preload("res://Scenes/Units/golem.tscn"),
	preload("res://Scenes/Units/PC/petamer/petamer.tscn"),
	preload("res://Scenes/Units/PC/soulbound/soulbound.tscn"),
	preload("res://Scenes/Units/PC/orbath/orbath.tscn"),
	preload("res://Scenes/Units/PC/zac/zac.tscn"),
]

var dungeon_wave_formations: Dictionary = {
	Zone.PUTRID_LAYERS:[
		{
			"boss_1":[
				{ "type": EnemyType.PUTRID_ABOMINATION, "position": Vector2(350, 250) },
			],
			"formation_1":[
				{ "type": EnemyType.FLESH_GOUL, "position": Vector2(250, 350) },
				{ "type": EnemyType.FLESH_GOUL, "position": Vector2(350, 350) },
				{ "type": EnemyType.FLESH_GOUL, "position": Vector2(450, 350) },
				{ "type": EnemyType.FLESH_GOUL, "position": Vector2(550, 350) },
			],
			"formation_2":[
				{ "type": EnemyType.FLESH_GOUL, "position": Vector2(50, 350) },
				{ "type": EnemyType.FLESH_GOUL, "position": Vector2(250, 350) },
				{ "type": EnemyType.FLESH_GOUL, "position": Vector2(550, 350) },
				{ "type": EnemyType.FLESH_GOUL, "position": Vector2(750, 350) },
			],
		}
	]
}


var dungeon_scaling: Dictionary = {
	"tier_1":{
		"base_health_multiplier": 1.0,
		"base_health_increase_per_tenth_room": 0.1,
		"base_attack_multiplier": 1.0,
		"base_attack_increase_per_tenth_room": 0.1,
	},
	"tier_2":{
		"base_health_multiplier": 1.2,
		"base_health_increase_per_wave": 0.2,
		"base_attack_multiplier": 1.2,
		"base_attack_increase_per_wave": 0.2,
	}
}

# Inventory
var backpack_contents_as_entities: Array[Entity]
var backpack_contents_as_packed_scenes: Array[PackedScene] = [
	preload("res://Scenes/Weapons/burst_staff.tscn"),
	preload("res://Scenes/Weapons/clobber_club.tscn"),
]

func _ready() -> void:
	initialize_data()

# Initializations
func initialize_data() -> void:
	_initialize_owned_units()
	_initialize_backpack_contents()
	dungeon_data_loaded.emit()

func _initialize_owned_units():
	for u in _available_units_as_packed_scenes:
		var entity_instance: Entity = u.instantiate()
		available_units_as_entities.append(entity_instance)

func _initialize_backpack_contents():
	for loot_entry in PlayerData.dungeon_loot:
		var item_id: String = loot_entry["item_id"]
		if not ITEM_REGISTRY.has(item_id):
			push_warning("DungeonData: No scene registered for item_id: " + item_id)
			continue
		var scene: PackedScene = load(ITEM_REGISTRY[item_id])
		var entity_instance: Entity = scene.instantiate()
		backpack_contents_as_entities.append(entity_instance)

func update_dungeon_team_entity(updated_entity: Entity):
	for e in updated_entity:
		if e.name == updated_entity.name:
			e = updated_entity
			break

func set_unit_entity_weapon(unit_entity: Entity, weapon_entity: Entity) -> Entity:
	var weapon_slot: Node = unit_entity.get_node("Components/WeaponSlotComponent")
	
	var old_weapon: Entity = null
	for child in weapon_slot.get_children():
		old_weapon = child
		weapon_slot.remove_child(child)
	
	weapon_slot.add_child(weapon_entity)
	return old_weapon

func get_room_formations(zone: String, room_number: int) -> Array:
	var zone_formations: Array = dungeon_wave_formations.get(zone, [])
	if zone_formations.is_empty():
		return []

	var is_boss_room: bool = room_number % 10 == 0

	# Collect all formations of the right type across every dict in the array
	var pool: Array = []
	for formation_dict in zone_formations:
		for key in formation_dict.keys():
			if is_boss_room and key.begins_with("boss"):
				pool.append(formation_dict[key])
			elif not is_boss_room and key.begins_with("formation"):
				pool.append(formation_dict[key])

	if pool.is_empty():
		return []

	return pool[randi() % pool.size()]
