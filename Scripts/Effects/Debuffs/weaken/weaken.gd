extends Debuff
class_name Weaken

var damage_modifier: float = 0.25

func _init() -> void:
	id = "weaken"
	display_name = "Weaken"
	duration = 5
	stacks = 1

func apply(_target: Entity) -> void:
	warer.health_component.pre_damage_taken.connect(effect)

func effect(target: Entity, _amount: int, _is_crit: bool):
	if is_instance_valid(target):
		target.health_component.final_damage_taken_modifier += damage_modifier
