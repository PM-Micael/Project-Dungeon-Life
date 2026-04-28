extends Node

# Units
var dungeon_team: Array[Entity]
var available_units_as_entities: Array[Entity]
var _available_units_as_packed_scenes: Array[PackedScene] = [
	preload("res://Scenes/Units/goblin.tscn"),
	preload("res://Scenes/Units/golem.tscn"),
	preload("res://Scenes/Units/petamer/petamer.tscn"),
	preload("res://Scenes/Units/soulbound.tscn"),
	preload("res://Scenes/Units/orbath.tscn"),
	preload("res://Scenes/Units/zac/zac.tscn"),
]

const type_skeleton: String = "skeleton"

var enemy_formations: Array = [
	[
		{ "type": "skeleton", "position": Vector2(0, -0) },
		{ "type": "skeleton", "position": Vector2(310, 40) },
		{ "type": "skeleton", "position": Vector2(410, 90) },
		{ "type": "skeleton", "position": Vector2(510, 140) },
	],
	[
		{ "type": "skeleton", "position": Vector2(210, -110) },
		{ "type": "skeleton", "position": Vector2(310, -110) },
		{ "type": "skeleton", "position": Vector2(410, -110) },
		{ "type": "skeleton", "position": Vector2(010, -10) },
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
