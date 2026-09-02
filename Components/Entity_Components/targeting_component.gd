extends Node2D
class_name TargetingComponent

enum TYPE {
	CLOSEST,
	FURTHEST,
	ALL,
	ALL_IN_ATTACK_RANGE,
	ALL_CLOSE_3x3
}

@onready var parent_entity: Entity = get_parent().get_parent()

var current_target: Entity
var targets: Array[Entity]

func select_all_targets(target_team: String):
	targets.clear()
	var enemies = get_tree().get_nodes_in_group(target_team)
	if enemies.is_empty():
		return
	
	for enemy in enemies:
		targets.append(enemy)

func select_targets_in_attack_range(target_team: String):
	targets.clear()
	
	var enemies = get_tree().get_nodes_in_group(target_team)
	if enemies.is_empty():
		return
	
	var _targets: Array[Entity]
	for e in enemies:
		if e.targetable_component == null:
			continue
		
		if not e.targetable_component.is_targetable:
			continue
		
		if (parent_entity.position.distance_to(e.global_position) <=
		parent_entity.attack_component.attack_range+50):
			_targets.append(e)
	
	return _targets

func select_closest_target(target_team: String = "") -> Array[Entity]:
	var _targets: Array
	if target_team == "":
		_targets.append(get_tree().get_nodes_in_group("Team 1"))
		_targets.append(get_tree().get_nodes_in_group("Team 2"))
	else:
		_targets = get_tree().get_nodes_in_group(target_team)

	if _targets.is_empty():
		return []
	
	var closest_target = null
	
	for t in _targets:
		if t.targetable_component == null:
			continue
		
		if not t.targetable_component.is_targetable:
			continue
		
		if closest_target == null:
			closest_target = t
			continue
		
		if (parent_entity.global_position.distance_to(t.global_position) < 
		   parent_entity.global_position.distance_to(closest_target.global_position)):
			closest_target = t
			
	current_target = closest_target
	return [closest_target]

func select_close_target(target_team: String):
	targets.clear()
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
	
	if (
		closest_enemy != null
		and closest_enemy.targetable_component != null
		and closest_enemy.targetable_component.is_targetable
		):
		targets.append(closest_enemy)
