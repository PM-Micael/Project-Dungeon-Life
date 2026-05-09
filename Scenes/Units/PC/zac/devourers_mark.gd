extends Affliction
class_name DevourersMark

func _init() -> void:
	id = "effect_debuff_devourers_mark"
	display_name = "Devourer's mark"
	duration = 7
	stacks = 1

func apply(target: Entity) -> void:
	debuff_effect()

func debuff_effect():
	warer.health_component.damage_taken.connect(_on_warer_took_damage)

func _on_warer_took_damage(attacker: Entity, _is_crit: bool):
	if not is_instance_valid(owner):
		return
	if warer.health_component.current_health <= warer.health_component.max_health * 0.05:
		print(owner.display_name + " Devourered")
		owner.devour_stacks += 1
		warer.health_component.die(attacker)
