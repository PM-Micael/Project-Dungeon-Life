extends Node2D
class_name DungeonSelection

# DUNGEON SELECT VARIABLES
var dungeons: Array
var selected_dungeon_name: String
var selected_dungeon_index: int = 0:
	set(value):
		if (selected_dungeon_index + value) > dungeons.size():
			selected_dungeon_index = 0
		elif (selected_dungeon_index + value) < 0:
			selected_dungeon_index = dungeons.size() -1
			
		_update_label()

@onready var run_manager: RunManager = get_parent().get_parent().get_node("RunManager")

@onready var dungeon_select: Node2D = $DungeonSelect
@onready var dungeon_label: Label = $DungeonSelect/Dungeon/DungeonLabel
@onready var previous_button: Button = $DungeonSelect/Dungeon/PreviousButton
@onready var next_button: Button = $DungeonSelect/Dungeon/NextButton
@onready var continue_button: Button = $DungeonSelect/ContinueButton

# UNIT SELECT VARIABLES
@onready var unit_select: Node2D = $UnitSelect
@onready var start_button: Button = $UnitSelect/StartButton

var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
var team_units: Array[EntityContainer] = []
var taken_unit_indexes: Array[int] = []
var slot_indexes: Array[int] = []

# BASE SETUP
func _ready() -> void:
	initialize_data()

func initialize_data():
	dungeon_select.visible = true
	unit_select.visible = false
	
	dungeons = DungeonData.DUNGEONS.values()
	
	_connect_events()
	_update_label()

func _connect_events():
	previous_button.pressed.connect(_on_previous_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	continue_button.pressed.connect(_continue_button_pressed)
	start_button.pressed.connect(_start_button_pressed)

# SELECT DUNGEON LOGIC

func _on_previous_button_pressed():
	selected_dungeon_index += 1

func _on_next_button_pressed():
	selected_dungeon_index -= 1

func _update_label():
	selected_dungeon_name = dungeons[selected_dungeon_index]
	dungeon_label.text = selected_dungeon_name

func _continue_button_pressed():
	dungeon_select.visible = false
	unit_select.visible = true
	team_units.append(_roll_unit())
	team_units.append(_roll_unit())
	team_units.append(_roll_unit())
	_display_units()

# ROLL UNITS LOGIC

func _roll_unit() -> EntityContainer:
	var unit_keys = GameData.UNIT.PLAYER.keys()
	var r_index: int = randi_range(0, unit_keys.size() - 1)
	while taken_unit_indexes.has(r_index):
		r_index = randi_range(0, unit_keys.size() - 1)
	
	taken_unit_indexes.append(r_index)
	slot_indexes.append(r_index)
	
	var unit_id: String = unit_keys[r_index]
	var unit_scene: PackedScene = load("res://Scenes/Units/PC/" + unit_id + "/" + unit_id + ".tscn")
	var unit_instance: Unit = unit_scene.instantiate()
	
	var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
	entity_container_instance.name = "EntityContainer_" + unit_id
	entity_container_instance.entity = unit_instance
	
	return entity_container_instance

func _reroll_unit(index: int):
	var old_index = slot_indexes[index]
	slot_indexes.remove_at(index)
	team_units[index] = _roll_unit()
	slot_indexes.insert(index, slot_indexes.pop_back())
	taken_unit_indexes.erase(old_index)  # erase AFTER rolling so it can't be picked
	
	var units_container = $UnitSelect/UnitsContainer
	units_container.get_node("NodeContainer_" + str(index)).queue_free()
	_display_unit(index, units_container, false)

func _display_units():
	var units_container = $UnitSelect/UnitsContainer
	for child in units_container.get_children():
		child.queue_free()
	for i in team_units.size():
		_display_unit(i, units_container, true)

func _display_unit(index: int, units_container: Node2D, button_on: bool):
	var unit_container = team_units[index]
	
	var node_container = Node2D.new()
	node_container.name = "NodeContainer_" + str(index)
	node_container.position = Vector2(125 + (275 * index), 150)
	units_container.add_child(node_container)
	
	unit_container.scale = Vector2(2, 2)
	node_container.add_child(unit_container)
	
	var unit_id: String = unit_container.entity.id
	var weapon_id: String = GameData.UNIT.PLAYER[unit_id][GameData.KEY.SIGNATURE_WEAPON]
	var weapon_scene: PackedScene = load(GameData.ITEM.WEAPON[weapon_id]["scene"])
	var weapon_instance: Entity = weapon_scene.instantiate()
	
	var weapon_container: EntityContainer = entity_container_scene.instantiate()
	weapon_container.entity = weapon_instance
	weapon_container.position = Vector2(0, 125)
	node_container.add_child(weapon_container)
	
	if button_on:
		var reroll_button = Button.new()
		reroll_button.text = "Reroll"
		reroll_button.position = Vector2(-25, 200)
		reroll_button.pressed.connect(_reroll_unit.bind(index))
		node_container.add_child(reroll_button)

func _start_button_pressed():
	var formation: Array[Dictionary] = []
	var loop_count: int = 0
	for unit_container in team_units:
		var unit_id: String = unit_container.entity.id
		var weapon_id: String = GameData.UNIT.PLAYER[unit_id][GameData.KEY.SIGNATURE_WEAPON]
		formation.append({
			"unit_name": unit_id,
			"weapon_id": weapon_id,
			"weapon_star_level": 1,
			"starting_position": Vector2(250 + (100*loop_count), 450)
		})
		loop_count += 1
	
	DungeonData.roll_dungeon_zone()
	
	PlayerData.current_room_enemy_formation = DungeonData.get_room_formations(
		PlayerData.current_zone,
		PlayerData.dungeon_room)
	
	print(selected_dungeon_name)
	match selected_dungeon_name:
		DungeonData.DUNGEONS.THE_DUNGEON:
			PlayerData.dungeon_team_formation_the_dungeon = formation
			PlayerData.dungeon_run_ongoing_the_dungeon = true
	
	
