extends Node

signal dungeon_data_loaded

const DUNGEONS: Dictionary = {
	THE_DUNGEON = "The Dungeon"
}

const EnemyType: Dictionary = {
	FLESH_GOUL = "flesh_goul",
	SPITTER = "spitter",
	FLESH_MUTANT = "flesh_mutant",
	SCORCHED_WANDERER = "scorched_wanderer",
	PUTRID_ABOMINATION = "putrid_abomination",
}

const ITEM_REGISTRY: Dictionary = {
	"crag_chunk": "res://Scenes/Weapons/crag_chunk/crag_chunk.tscn",
	"heat_seeker": "res://Scenes/Weapons/heat_seeker/heat_seeker.tscn",
	"splinter": "res://Scenes/Weapons/splinter/splinter.tscn",
	"cursed_lantern": "res://Scenes/Weapons/cursed_lantern/cursed_lantern.tscn",
	"rumble_gloves": "res://Scenes/Weapons/rumble_gloves/rumble_gloves.tscn",
}

# Units
var available_units_as_entities: Array[Entity]
var _available_units_as_packed_scenes: Array[PackedScene] = [
	preload("res://Scenes/Units/PC/devourer_of_ghouls/devourer_of_ghouls.tscn"),
]

var dungeon_wave_formations: Dictionary = {
	GameData.ZONE.SCORCHED_GROUNDS:[
		{
			"boss_1":[
				{ "type": EnemyType.PUTRID_ABOMINATION, "position": Vector2(350, 250) },
			],
			"formation_1":[
				{ "type": EnemyType.SCORCHED_WANDERER, "position": Vector2(250, 350) },
				{ "type": EnemyType.SCORCHED_WANDERER, "position": Vector2(350, 350) },
				{ "type": EnemyType.SCORCHED_WANDERER, "position": Vector2(450, 350) },
				{ "type": EnemyType.SCORCHED_WANDERER, "position": Vector2(550, 350) },
			],
			"formation_2":[
				{ "type": EnemyType.SCORCHED_WANDERER, "position": Vector2(50, 350) },
				{ "type": EnemyType.SCORCHED_WANDERER, "position": Vector2(250, 350) },
				{ "type": EnemyType.SCORCHED_WANDERER, "position": Vector2(550, 350) },
				{ "type": EnemyType.SCORCHED_WANDERER, "position": Vector2(750, 350) },
			]
		}
	],
	GameData.ZONE.PUTRID_LAYERS:[
		{
			"boss_1":[
				{ "type": EnemyType.PUTRID_ABOMINATION, "position": Vector2(350, 250) },
			],
			"formation_1":[
				{ "type": EnemyType.FLESH_MUTANT, "position": Vector2(350, 350) },
				{ "type": EnemyType.SPITTER, "position": Vector2(350, 250) },
			],
			"formation_2":[
				{ "type": EnemyType.FLESH_MUTANT, "position": Vector2(250, 350) },
				{ "type": EnemyType.SPITTER, "position": Vector2(450, 250) },
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

func _ready() -> void:
	initialize_data()

# Initializations
func initialize_data() -> void:
	_initialize_owned_units()
	dungeon_data_loaded.emit()

func _initialize_owned_units():
	for u in _available_units_as_packed_scenes:
		var entity_instance: Entity = u.instantiate()
		available_units_as_entities.append(entity_instance)

func roll_dungeon_zone() -> String:
	var zone_keys: Array = GameData.ZONE.values()
	var new_zone: String = zone_keys[randi_range(0, zone_keys.size()-1)]
	while new_zone == PlayerData.current_zone:
		new_zone = zone_keys[randi_range(0, zone_keys.size()-1)]
	
	PlayerData.current_zone = new_zone
	print("Rolled new zone: "+new_zone)
	
	return PlayerData.current_zone

func check_and_merge_backpack_items() -> void:
	var groups: Dictionary[String, int] = {}
	
	for entity in PlayerData.dungeon_loot_as_entities:
		var wc: WeaponComponent = entity.get_node_or_null("Components/WeaponComponent")
		if wc == null:
			continue

		var key: String = entity.id + ":" + str(wc.star_level)
		groups[key] = groups.get(key, 0) + 1

		if groups[key] == 3:
			
			var removed: int = 0
			for e in PlayerData.dungeon_loot_as_entities.duplicate():
				if removed == 2:
					break
				if e == entity:
					continue
				var ewc: WeaponComponent = e.get_node_or_null("Components/WeaponComponent")
				if ewc != null and e.id == entity.id and ewc.star_level == wc.star_level:
					PlayerData.dungeon_loot_as_entities.erase(e)
					e.queue_free()
					removed += 1
			
			wc.star_level += 1

			groups[key] = 0
			var new_key: String = entity.id + ":" + str(wc.star_level)
			groups[new_key] = groups.get(new_key, 0) + 1

	PlayerData.save_backpack_as_loot()

func set_unit_entity_weapon(unit_entity: Entity, weapon_entity: Entity) -> Entity:
	var weapon_slot: Node = unit_entity.get_node("Components/WeaponSlotComponent")
	
	var old_weapon: Entity = null
	for child in weapon_slot.get_children():
		old_weapon = child
		weapon_slot.remove_child(child)
	
	weapon_slot.add_child(weapon_entity)
	return old_weapon

func change_unit_weapon(unit_entity: Entity, new_weapon_entity: Entity):
	print("Changing unit weapon")
	var unit_weapon_slot_component: Entity = unit_entity.get_node("Components/WeaponSlotComponent")
	var unit_weapon = unit_weapon_slot_component.get_child(0)
	if unit_weapon != null:
		unit_weapon.free()
	
	unit_weapon_slot_component.add_child(new_weapon_entity)
	
	# Update the selection
	var unit_selection_container_entities: Array[EntityContainer] = get_parent().unit_selection_frame_entity_containers_node.get_children()
	for u in unit_selection_container_entities:
		if u.entity.display_name == unit_entity.display_name:
			u.entity = unit_entity

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
