extends Entity

@export var basic_attack_damage: int = 1

func _init() -> void:
	id = "rumble_gloves"

func _ready() -> void:
	name = "rumble_gloves"
	display_name = "Rumble Gloves"
	weapon_component.weapon_energy_gained_on_damage_taken = 3
	weapon_component.set_stats_absolute(basic_attack_damage)
	weapon_component.use_weapon_skill.connect(_weapon_skill)

func _calculate_damage() -> int:
	var wearer: Entity = weapon_component.entity_holding_weapon
	var is_crit: bool = false
	if weapon_component.ability_can_crit:
		is_crit = wearer.attack_component.roll_crit()
	
	var total_damage = wearer.attack_component.get_total_attack_damage(is_crit)
	
	return total_damage

func _weapon_skill(targets: Array[Entity]):
	print("3x crit")
