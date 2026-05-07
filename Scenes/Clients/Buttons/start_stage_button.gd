# Scenes/Clients/Buttons/start_stage_button.gd
extends Button

@onready var parent: TeamLineupMenu = get_parent()

func _ready():
	pressed.connect(_button_pressed)

func _button_pressed():
	PlayerData.save_dungeon_team_as_formation(parent.board.friendly_units)
	var board_scene: GameBoard = get_node_or_null("/root/TeamLineupMenu/Board")
	var friendly_container_nodes := parent.get_node("Board/Characters/FriendlyUnits").get_children()
	var enemy_container_nodes := parent.get_node("Board/Characters/EnemyUnits").get_children()

	for f in friendly_container_nodes:
		f.free()

	for e in enemy_container_nodes:
		e.free()

	if board_scene:
		board_scene.place_friendly_units_on_board()
		board_scene.place_enemy_units_on_board()

	parent.start_game()
