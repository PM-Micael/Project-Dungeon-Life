extends Node2D

@onready var start_button: Button = get_node("StartButton")
@onready var loading_label: Label = get_node("LoadingLabel")

func _ready() -> void:	
	print("Loading player data")
	PlayerData.load_player_data()
	await PlayerData.player_data_loaded
	print("Loading Dungeon data")
	DungeonData.initialize_data()
	start_button.pressed.connect(_on_start_button_pressed)
	loading_label.visible = false
	start_button.visible = true
	print("Game ready!")

func _window_setup():
	var window = get_window()
	window.borderless = true

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Clients/team_lineup_menu.tscn")
