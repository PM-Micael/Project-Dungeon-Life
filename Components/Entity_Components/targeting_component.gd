extends Node2D
class_name TargetingComponent

@onready var parent_entity: Entity = get_parent().get_parent()

var target: Entity

func _physics_process(delta: float) -> void:
	select_closest_target(parent_entity.hostile_team)

func select_closest_target(target_team: String):
	var enemies = get_tree().get_nodes_in_group(target_team)
	if enemies.is_empty():
		return
	
	var closest_enemy = null
	
	for e in enemies:
		if e.targetable_component == null:
			continue
		
		if not e.targetable_component.is_targetable:
			continue
		
		if closest_enemy == null:
			closest_enemy = e
			continue
		
		if (parent_entity.global_position.distance_to(e.global_position) < 
		   parent_entity.global_position.distance_to(closest_enemy.global_position)):
			closest_enemy = e
	
	if closest_enemy != null and closest_enemy.targetable_component != null and closest_enemy.targetable_component.is_targetable:
		target = closest_enemy
	else:
		target = null
