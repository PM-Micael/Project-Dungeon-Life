extends Debuff
class_name BloodFlies

var max_health_heal: float = 0.2

func _init() -> void:
	id = "blood_flies"
	display_name = "Blood Flies"
	duration = 6
	stacks = 1

func apply(target: Entity) -> void:
	warer.health_component.damage_taken.connect(_on_warer_took_damage)

func _on_warer_took_damage(attacker: Unit):
	if attacker == owner and warer.health_component.current_health <= warer.health_component.max_health * 0.05:
		print(owner.display_name + " Devourered")
		owner.devour_stacks += 1
		warer.health_component.die()
