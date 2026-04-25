extends Debuff
class_name DevourersMark

func _init() -> void:
	id = "effect_debuff_devourers_mark"
	display_name = "Devourer's mark"
	duration = 7
	stacks = 1

func apply(target: Entity) -> void:
	warer.health_component.damage_taken.connect(_on_warer_took_damage)

func _on_warer_took_damage(attacker: Unit):
	#check applier
	if attacker == owner and warer.health_component.current_health <= warer.health_component.max_health * 0.05:
		print(owner.display_name + " Devourered")
		owner.devour_stacks += 1
		warer.health_component.die()
