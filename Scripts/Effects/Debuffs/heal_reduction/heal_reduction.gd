extends Debuff
class_name HealReduction

var reduced_healing: float = 0.4

func _init() -> void:
	id = "heal_reduction"
	display_name = "Heal Reduction"
	duration = 5
	stacks = 1

func apply(_target: Entity) -> void:
	warer.health_component.pre_heal.connect(effect)

func effect(target: Entity, _amount: int):
	target.health_component.final_heal_modifier -= reduced_healing
