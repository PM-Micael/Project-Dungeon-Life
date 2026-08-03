extends Debuff
class_name AttackSpeedDown

var attack_timer_multiplier: float = 1.5  # e.g. 30% faster attacks per stack

func _init(_duration: int = -1, _stacks: int = 1) -> void:
	id = "attack_speed_down"
	display_name = "Attack Speed Down"
	duration = _duration  # Infinite — controlled by stack removal, not time
	stacks = _stacks

func apply(_target: Entity) -> void:
	var ac: AttackComponent = warer.attack_component
	if ac != null:
		ac.timer.wait_time = get_added_speed_timer(ac)

func remove(_target: Entity) -> void:
	var ac: AttackComponent = warer.attack_component
	if ac != null:
		ac.timer.wait_time = get_added_speed_timer(ac)

func get_added_speed_timer(ac: AttackComponent) -> float:
	var new_speed = ac.base_attack_speed * attack_timer_multiplier
	return new_speed - ac.base_attack_speed
