extends Node2D
class_name MovmentComponent

@onready var parent_entity: Entity = get_parent().get_parent()

@onready var timer: Timer = $Timer

func move_to_target(target) -> bool:
	var delta = target.global_position - global_position
	
	if (abs(delta.y) == 0 && abs(delta.x) == 100) || (abs(delta.x) == 0 && abs(delta.y) == 100): # Attack range
		return true
	else:
		if abs(delta.y) > abs(delta.x):
			parent_entity.global_position.y += sign(delta.y) * 100
		else:
			parent_entity.global_position.x += sign(delta.x) * 100
	
	return false
