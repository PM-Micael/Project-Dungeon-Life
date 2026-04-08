extends Button

@onready var parent: TeamLineupMenu = get_parent()
@onready var game_scene 

func _ready():
	game_scene = preload("res://Scenes/Clients/game.tscn")
	pressed.connect(_button_pressed)

func _button_pressed():
	var board_scene: GameBoard = get_node_or_null("/root/TeamLineupMenu/Board")
	var friendly_container_nodes: = parent.get_node("Board/Characters/FriendlyUnits").get_children()
	var enemy_conainer_nodes = parent.get_node("Board/Characters/EnemyUnits").get_children()
	
	for f:EntityContainer in friendly_container_nodes:
		for i:Entity in board_scene.friendly_units:
			if f.entity.name == i.name:
				i.position = f.position
				break
		f.free()
	
	for e in enemy_conainer_nodes:
		e.free()
	
	var in_game_instance: Node2D = game_scene.instantiate()
	
	board_scene.friendly_units = parent.player_characters
	board_scene.enemy_units = parent.enemy_characters
	
	if board_scene:
		board_scene.get_parent().remove_child(board_scene)
		board_scene.place_friendly_units_on_board()
		board_scene.place_enemy_units_on_board()
		in_game_instance.add_child(board_scene)
	
	get_tree().root.add_child(in_game_instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = in_game_instance
