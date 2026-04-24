extends Node2D
class_name GameBoard

signal round_over

@onready var enemy_units_node: Node2D = get_node("Characters/EnemyUnits")
@onready var friendly_units_node: Node2D = get_node("Characters/FriendlyUnits")
@onready var enemy_units: Array[Entity]

var game_on: bool = false

func _physics_process(delta: float) -> void:
	if game_on:
		_check_units_alive()

func place_friendly_units_on_board():
	for u in DungeonData.dungeon_team:
		friendly_units_node.add_child(u)

func place_enemy_units_on_board():
	if enemy_units and enemy_units.size() > 0:
		for u in enemy_units:
			enemy_units_node.add_child(u)
	else:
		print("No enemy units")

func _check_units_alive():
	var enemies: Array = enemy_units_node.get_children()
	var friendlies: Array = friendly_units_node.get_children()
	
	if enemies.size() == 0:
		print("You win")
		game_on = false
		round_over.emit()
	elif friendlies.size() == 0:
		print("You loose")
		game_on = false
		round_over.emit()
	
