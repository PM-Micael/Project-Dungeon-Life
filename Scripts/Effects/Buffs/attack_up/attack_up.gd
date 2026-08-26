extends Buff
class_name AttackUp

var attack_multiplier: float = 0.10

func _init() -> void:
	id = "attack_up"
	display_name = "Attack Up"
	duration = 4.0
	stacks = 1

func apply(_target: Entity) -> void:
	var ac: AttackComponent = warer.attack_component
	if ac != null:
		ac.attack_damage += get_added_damage(ac)

func remove() -> void:
	var ac: AttackComponent = warer.attack_component
	if ac != null:
		ac.attack_damage -= get_added_damage(ac)

func get_added_damage(ac: AttackComponent) -> int:
	return int((ac.base_attack_damage * (1.0 + attack_multiplier)) - ac.base_attack_damage)
