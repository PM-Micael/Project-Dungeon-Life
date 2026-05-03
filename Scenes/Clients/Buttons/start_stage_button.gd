# Scenes/Clients/Buttons/start_stage_button.gd
extends Button

@onready var parent: TeamLineupMenu = get_parent()

func _ready():
	pressed.connect(_button_pressed)

func _button_pressed():
	var board_scene: GameBoard = get_node_or_null("/root/TeamLineupMenu/Board")
	var friendly_container_nodes := parent.get_node("Board/Characters/FriendlyUnits").get_children()
	var enemy_container_nodes := parent.get_node("Board/Characters/EnemyUnits").get_children()

	for f: EntityContainer in friendly_container_nodes:
		for i: Entity in DungeonData.dungeon_team:
			if f.entity.name == i.name:
				i.position = f.position
				break
		f.free()

	for e in enemy_container_nodes:
		e.free()

	if board_scene:
		board_scene.place_friendly_units_on_board()
		board_scene.place_enemy_units_on_board()

	parent.start_game()
