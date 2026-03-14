extends Node2D
class_name TargetingComponent

@onready var parent_entity: Entity = get_parent().get_parent()

var target

func select_target(target_team: String):
	var enemies = get_tree().get_nodes_in_group(target_team)
	if enemies.is_empty():
		return
	
	var closest_enemy = enemies[0]
	
	for e in enemies:
		if (
			parent_entity.global_position.distance_to(e.global_position) <
			parent_entity.global_position.distance_to(closest_enemy.global_position)
		):
			closest_enemy = e
	
	target = closest_enemy
