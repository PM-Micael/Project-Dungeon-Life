extends Button

@onready var game_scene 
@onready var team_loadout_menu: TeamLoadoutMenu = get_parent()

func _ready():
	game_scene = preload("res://Scenes/Clients/team_lineup_menu.tscn")
	pressed.connect(_button_pressed)

func _button_pressed():
	var team_lineup_menu: TeamLineupMenu = game_scene.instantiate()
	
	get_tree().root.add_child(team_lineup_menu)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = team_lineup_menu
