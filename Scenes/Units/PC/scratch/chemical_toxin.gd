extends Debuff
class_name ChemicalToxin

func _init() -> void:
	id = "chemical_toxin"
	display_name = "Chemical Toxin"
	duration = 4
	stacks = 1

# This is wrong. Scratch should apply it

func apply(target: Entity) -> void:
	warer.health_component.damage_taken.connect(_on_warer_took_damage)

func _on_warer_took_damage(attacker: Unit, is_crit: bool):
	if attacker == owner and is_crit:
		print(owner.display_name + " applieed [chemical toxin]")
