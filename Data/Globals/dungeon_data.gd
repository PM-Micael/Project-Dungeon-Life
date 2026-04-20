extends Node

# Units
var dungeon_team: Array[Entity]
var available_units_as_entities: Array[Entity]
var _available_units_as_packed_scenes: Array[PackedScene] = [
	preload("res://Scenes/Characters/goblin.tscn"),
	preload("res://Scenes/Characters/golem.tscn"),
	preload("res://Scenes/Characters/petamer.tscn"),
	preload("res://Scenes/Characters/soulbound.tscn"),
	preload("res://Scenes/Characters/orbath.tscn"),
]

const type_skeleton: String = "skeleton"

var enemy_formations: Array = [
	[
		{ "type": "skeleton", "position": Vector2(-150, -250) },
		{ "type": "skeleton", "position": Vector2(-50, -250) },
		{ "type": "skeleton", "position": Vector2(50, -250) },
		{ "type": "skeleton", "position": Vector2(150, -250) },
	],
	[
		{ "type": "skeleton", "position": Vector2(-350, -50) },
		{ "type": "skeleton", "position": Vector2(-150, -50) },
		{ "type": "skeleton", "position": Vector2(150, -50) },
		{ "type": "skeleton", "position": Vector2(350, -50) },
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

func set_unit_entity_weapon(unit_entity: Entity, weapon_entity: Entity):
	unit_entity.reparent(weapon_entity.get_parent())
	weapon_entity.reparent(unit_entity.get_parent())
	
	##Drop other weapon
	#if unit_weapons != null or not unit_weapons.size() <= 0:
		## Has weapon's
		#for i in unit_weapons:
			#i.free()
	
	unit_entity.get_node("Components/WeaponSlotComponent").add_child(weapon_entity)
