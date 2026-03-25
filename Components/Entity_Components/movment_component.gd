extends Node2D
class_name MovmentComponent

@export var stop_range = 100

@onready var parent_entity: Entity = get_parent().get_parent()
@onready var timer: Timer = $Timer

var is_in_target_range: bool = false

func _ready() -> void:
	timer.wait_time = 1.1

func move_to_target(target: Entity) -> bool:
	var delta = target.global_position - parent_entity.global_position
	
	if parent_entity.attack_component != null:
		print(str(parent_entity.attack_component.attack_range))
		stop_range = parent_entity.attack_component.attack_range
	else:
		stop_range = 100
	
	if ((abs(delta.y) <= stop_range and
	abs(delta.x) <= stop_range) or
	(abs(delta.x) <= stop_range and
	abs(delta.y) <= stop_range)
	):
		is_in_target_range = true
	else:
		if abs(delta.y) > abs(delta.x):
			parent_entity.global_position.y += sign(delta.y) * 100
		else:
			parent_entity.global_position.x += sign(delta.x) * 100
	
	return is_in_target_range
