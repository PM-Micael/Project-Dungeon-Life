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
		var collision_component: CollisionComponent = parent_entity.get_node_or_null("Components/CollisionComponent")
		
		var preferred_step: Vector2 = parent_entity.global_position
		var fallback_step: Vector2 = parent_entity.global_position
		if abs(delta.y) > abs(delta.x):
			preferred_step.y += sign(delta.y) * 100
			fallback_step.x += sign(delta.x) * 100
		else:
			preferred_step.x += sign(delta.x) * 100
			fallback_step.y += sign(delta.y) * 100
		
		if collision_component != null:
			if collision_component.is_position_free(preferred_step):
				collision_component.move_to(preferred_step)
			elif collision_component.is_position_free(fallback_step):
				collision_component.move_to(fallback_step)
			# else: both blocked, wait for next tick
		else:
			parent_entity.global_position = preferred_step
	
	return is_in_target_range
