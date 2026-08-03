extends Debuff
class_name AttackDown

var attack_multiplier: float = 0.10

func _init() -> void:
	id = "attack_down"
	display_name = "Attack Down"
	duration = 4.0
	stacks = 1

func apply(_target: Entity) -> void:
	var ac: AttackComponent = warer.attack_component
	if ac != null:
		ac.attack_damage -= get_removed_damage(ac)

func remove() -> void:
	var ac: AttackComponent = warer.attack_component
	if ac != null:
		ac.attack_damage += get_removed_damage(ac)

func get_removed_damage(ac: AttackComponent) -> int:
	return int((ac.base_attack_damage * (1.0 + attack_multiplier)) - ac.base_attack_damage)
