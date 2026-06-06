extends Node

signal dungeon_data_loaded

const DUNGEONS: Dictionary = {
	THE_DUNGEON = "The Dungeon"
}

const Zone: Dictionary = {
	PUTRID_LAYERS = "putrid_layers",
	SCORCHED_GROUNDS = "scorched_grounds"
}

const EnemyType: Dictionary = {
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
	"rumble_gloves": "res://Scenes/Weapons/rumble_gloves/rumble_gloves.tscn",
}

# Units
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
	Zone.SCORCHED_GROUNDS:[
		{
			"boss_1":[
				{ "type": EnemyType.PUTRID_ABOMINATION, "position": Vector2(350, 250) },
			],
			"formation_1":[
				{ "type": EnemyType.FLESH_GOUL, "position": Vector2(250, 350) },
			],
			"formation_2":[
				{ "type": EnemyType.FLESH_GOUL, "position": Vector2(50, 350) },
			],
		}
	],
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
