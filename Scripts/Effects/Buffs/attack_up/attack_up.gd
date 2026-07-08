extends Buff
class_name AttackUp

var attack_multiplier: float = 0.10

func _init() -> void:
	id = "attack_up"
	display_name = "Attack Up"
	duration = 4.0
	stacks = 1

func apply(_target: Entity) -> void:
	var ac: AttackComponent = warer.attack_componwent
	if ac != null:
		ac.attack_damage = int(ac.base_attack_damage * (1.0 + attack_multiplier))

func remove(_target: Entity) -> void:
	var ac: AttackComponent = warer.attack_component
	if ac != null:
		var attack_differrence: int = int((ac.base_attack_damage * (1.0 + attack_multiplier)) - ac.base_attack_damage)
		# Reverse the multiplier
		ac.attack_damage -= attack_differrence
