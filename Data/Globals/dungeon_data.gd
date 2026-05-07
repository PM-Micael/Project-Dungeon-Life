extends Node

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
	"room_1": [
		{
			"formation_1":[
				{ "type": "skeleton", "position": Vector2(250, 150) },
				{ "type": "skeleton", "position": Vector2(350, 150) },
				{ "type": "skeleton", "position": Vector2(450, 150) },
				{ "type": "skeleton", "position": Vector2(550, 150) },
			],
			"formation_2":[
				{ "type": "skeleton", "position": Vector2(50, 350) },
				{ "type": "skeleton", "position": Vector2(250, 350) },
				{ "type": "skeleton", "position": Vector2(550, 350) },
				{ "type": "skeleton", "position": Vector2(750, 350) },
			]
		}
	],
	"room_2":[
		{
			"formation_1":[
				{ "type": "skeleton", "position": Vector2(250, 150) },
				{ "type": "skeleton", "position": Vector2(350, 150) },
				{ "type": "skeleton", "position": Vector2(450, 150) },
				{ "type": "skeleton", "position": Vector2(550, 150) },
				{ "type": "skeleton", "position": Vector2(650, 150) },
			],
			"formation_2":[
				{ "type": "skeleton", "position": Vector2(50, 350) },
				{ "type": "skeleton", "position": Vector2(250, 350) },
				{ "type": "skeleton", "position": Vector2(350, 350) },
				{ "type": "skeleton", "position": Vector2(550, 350) },
				{ "type": "skeleton", "position": Vector2(750, 350) },
			]
		}
	],
	"room_3":[
		{
			"formation_1":[
				{ "type": "skeleton", "position": Vector2(150, 150) },
				{ "type": "skeleton", "position": Vector2(250, 150) },
				{ "type": "skeleton", "position": Vector2(350, 150) },
				{ "type": "skeleton", "position": Vector2(450, 150) },
				{ "type": "skeleton", "position": Vector2(550, 150) },
				{ "type": "skeleton", "position": Vector2(650, 150) },
			],
			"formation_2":[
				{ "type": "skeleton", "position": Vector2(50, 350) },
				{ "type": "skeleton", "position": Vector2(150, 150) },
				{ "type": "skeleton", "position": Vector2(250, 350) },
				{ "type": "skeleton", "position": Vector2(550, 350) },
				{ "type": "skeleton", "position": Vector2(650, 350) },
				{ "type": "skeleton", "position": Vector2(750, 350) },
			]
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

var enemy_formations: Array[Array] = [
	[
		{ "type": "skeleton", "position": Vector2(250, 150) },
		{ "type": "skeleton", "position": Vector2(350, 150) },
		{ "type": "skeleton", "position": Vector2(450, 150) },
		{ "type": "skeleton", "position": Vector2(550, 150) },
		{ "type": "flesh_goul", "position": Vector2(450, 50) },
	],
	[
		{ "type": "skeleton", "position": Vector2(50, 350) },
		{ "type": "skeleton", "position": Vector2(250, 350) },
		{ "type": "skeleton", "position": Vector2(550, 350) },
		{ "type": "skeleton", "position": Vector2(750, 350) },
		{ "type": "flesh_goul", "position": Vector2(450, 50) },
	]
]

# Inventory
var backpack_contents_as_entities: Array[Entity]
var backpack_contents_as_packed_scenes: Array[PackedScene] = [
	preload("res://Scenes/Weapons/burst_staff.tscn"),
	preload("res://Scenes/Weapons/clobber_club.tscn"),
]

# Initializations
func initialize_data() -> void:
		# Add code to fill owned units according to player progression if there are any
	_initialize_owned_units()
	_initialize_backpack_contents()

func _initialize_owned_units():
	for u in _available_units_as_packed_scenes:
		var entity_instance: Entity = u.instantiate()
		available_units_as_entities.append(entity_instance)

func _initialize_backpack_contents():
	for i in backpack_contents_as_packed_scenes:
		var entity_instance = i.instantiate()
		backpack_contents_as_entities.append(entity_instance)

# C.R.U.D
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
