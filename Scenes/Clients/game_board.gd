extends Node2D
class_name GameBoard

signal round_over(player_won: bool)

@onready var enemy_units_node: Node2D = get_node("Characters/EnemyUnits")
@onready var friendly_units_node: Node2D = get_node("Characters/FriendlyUnits")
@onready var enemy_units: Array[Unit]
@onready var friendly_units: Array[Unit]

var game_on: bool = false

func _physics_process(delta: float) -> void:
	if game_on:
		_check_units_alive()


func place_friendly_units_on_board():
	for u in friendly_units:
		friendly_units_node.add_child(u)

func place_enemy_units_on_board():
	for u in enemy_units:
		enemy_units_node.add_child(u)

func _check_units_alive():
	var enemies: Array = enemy_units_node.get_children()
	var friendlies: Array = friendly_units_node.get_children()
	
	if enemies.size() == 0:
		print("You win")
		game_on = false
		round_over.emit(true)
	elif friendlies.size() == 0:
		print("You loose")
		game_on = false
		round_over.emit(false)
	
