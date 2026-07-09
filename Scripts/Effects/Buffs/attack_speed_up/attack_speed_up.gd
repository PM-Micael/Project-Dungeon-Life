extends Buff
class_name AttackSpeedUp

var speed_multiplier: float = 0.7  # e.g. 30% faster attacks per stack

func _init() -> void:
	id = "attack_speed_up"
	display_name = "Attack Speed Up"
	duration = -1  # Infinite — controlled by stack removal, not time
	stacks = 1

func apply(_target: Entity) -> void:
	var ac: AttackComponent = warer.attack_component
	if ac != null:
		ac.timer.wait_time = ac.base_attack_speed * speed_multiplier

func remove() -> void:
	var ac: AttackComponent = warer.attack_component
	if ac != null:
		var speed_difference = ac.base_attack_speed * speed_multiplier - ac.base_attack_speed
		ac.timer.wait_time -= speed_difference
