extends Node2D

var dungeons: Array
var selected_dungeon_name: String
var selected_dungeon_index: int = 0:
	set(value):
		if (selected_dungeon_index + value) > dungeons.size():
			selected_dungeon_index = 0
		elif (selected_dungeon_index + value) < 0:
			selected_dungeon_index = dungeons.size() -1
			
		_update_label()

@onready var dungeon_label: Label = get_node("Dungeon/DungeonLabel")
@onready var previous_button: Button = get_node("Dungeon/PreviousButton")
@onready var next_button: Button = get_node("Dungeon/NextButton")

@onready var continue_button: Button = get_node("ContinueButton")

func _ready() -> void:
	dungeons = DungeonData.DUNGEONS.values()
	
	_connect_events()
	_update_label()

func _connect_events():
	previous_button.pressed.connect(_on_previous_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	continue_button.pressed.connect(_continue_button_pressed)

func _on_previous_button_pressed():
	selected_dungeon_index += 1

func _on_next_button_pressed():
	selected_dungeon_index -= 1

func _update_label():
	selected_dungeon_name = dungeons[selected_dungeon_index]
	dungeon_label.text = selected_dungeon_name

func _continue_button_pressed():
	print(selected_dungeon_name)
	match selected_dungeon_name:
		DungeonData.DUNGEONS.THE_DUNGEON:
			PlayerData.dungeon_run_ongoing_the_dungeon = true
		DungeonData.ZONE.PUTRID_LAYERS:
			PlayerData.dungeon_run_ongoing_putrid_layers = true
		DungeonData.ZONE.SCORCHED_GROUNDS:
			PlayerData.dungeon_run_ongoing_scorched_grounds = true
