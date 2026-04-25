extends Debuff
class_name DevourersMark

func _init() -> void:
	id = "effect_debuff_devourers_mark"
	display_name = "Devourer's mark"
	duration = 7
	stacks = 1

func _reset_state() -> void:
	warer.health_component.damage_taken.connect(_on_warer_took_damage)

func _on_warer_took_damage(owner: Unit):
	if warer.health_component.current_health == warer.health_component.max_health * 0.7:
		owner.devour_stacks += 1
		print("Get Devourered")
		warer.health_component.die()
