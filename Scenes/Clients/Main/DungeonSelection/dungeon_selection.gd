extends Node2D

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

@onready var dungeon_select: Node2D = $DungeonSelect
@onready var dungeon_label: Label = $DungeonSelect/Dungeon/DungeonLabel
@onready var previous_button: Button = $DungeonSelect/Dungeon/PreviousButton
@onready var next_button: Button = $DungeonSelect/Dungeon/NextButton
@onready var continue_button: Button = $DungeonSelect/ContinueButton

# UNIT SELECT VARIABLES
@onready var unit_select: Node2D = $UnitSelect
@onready var start_button: Button = $UnitSelect/StartButton

func _ready() -> void:
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
	_roll_units()

# ROLL UNITS LOGIC

func _roll_units():
	var unit_keys = GameData.UNIT.PLAYER.keys()
	var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
	var units: Array = []
	var taken_index: Array[int] = []
	var r_index: int
	
	var unit_count = 0
	while unit_count < 3:
		r_index = randi_range(0, unit_keys.size() - 1)
		while taken_index.has(r_index):
			r_index = randi_range(0, unit_keys.size() - 1)
		
		taken_index.append(r_index)
		
		var unit_id: String = unit_keys[r_index]
		var unit_scene: PackedScene = load("res://Scenes/Units/PC/" + unit_id + "/" + unit_id + ".tscn")
		var unit_instance: Unit = unit_scene.instantiate()
		
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
		entity_container_instance.name = "EntityContainer_" + unit_id
		entity_container_instance.entity = unit_instance
		
		units.append(entity_container_instance)
		unit_count += 1
	
	return units

func _start_button_pressed():
	print(selected_dungeon_name)
	match selected_dungeon_name:
		DungeonData.DUNGEONS.THE_DUNGEON:
			PlayerData.dungeon_run_ongoing_the_dungeon = true
		DungeonData.ZONE.PUTRID_LAYERS:
			PlayerData.dungeon_run_ongoing_putrid_layers = true
		DungeonData.ZONE.SCORCHED_GROUNDS:
			PlayerData.dungeon_run_ongoing_scorched_grounds = true
