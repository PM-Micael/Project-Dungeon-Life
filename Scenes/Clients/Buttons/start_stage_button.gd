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
		for i:Entity in Globals.dungeon_team:
			if f.entity.name == i.name:
				i.position = f.position
				break
		f.free()
	
	for e in enemy_conainer_nodes:
		e.free()
	
	var in_game_instance: Node2D = game_scene.instantiate()
	
	if board_scene:
		board_scene.get_parent().remove_child(board_scene)
		board_scene.place_friendly_units_on_board()
		board_scene.place_enemy_units_on_board()
		board_scene.game_on = true
		in_game_instance.add_child(board_scene)
	
	get_tree().root.add_child(in_game_instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = in_game_instance
