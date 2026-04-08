extends Node2D
class_name GameBoard

@onready var enemy_units_node: Node2D = get_node("Characters/EnemyUnits")
@onready var friendly_units_node: Node2D = get_node("Characters/FriendlyUnits")
@onready var enemy_units: Array[Entity]

func place_friendly_units_on_board():
	for u in Globals.dungeon_team:
		friendly_units_node.add_child(u)

func place_enemy_units_on_board():
	if enemy_units and enemy_units.size() > 0:
		for u in enemy_units:
			enemy_units_node.add_child(u)
	else:
		print("No enemy units")
