extends Buff
class_name AttackSpeedUp

var attack_timer_multiplier: float = 0.7  # e.g. 30% faster attacks per stack

func _init() -> void:
	id = "attack_speed_up"
	display_name = "Attack Speed Up"
	duration = -1  # Infinite — controlled by stack removal, not time
	stacks = 1

func apply(_target: Entity) -> void:
	var ac: AttackComponent = warer.attack_component
	if ac != null:
		ac.timer.wait_time -= get_removed_speed_timer(ac)

func remove() -> void:
	var ac: AttackComponent = warer.attack_component
	if ac != null:
		ac.timer.wait_time += get_removed_speed_timer(ac)

func get_removed_speed_timer(ac: AttackComponent) -> float:
	var new_speed = ac.base_attack_speed * attack_timer_multiplier
	return -new_speed + ac.base_attack_speed
