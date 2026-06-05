extends Unit

func _init() -> void:
	id = "scratch"
	passive_description = "Dealing critical damage applies chmical toxin to target hit.
		Chemical toxin deals damage every second to the target."
	base_health = 100
	attack_damage = 20
	attack_range = 300
	base_critical_percent_chance = 15
	base_critical_damage_multiplier = 1.3
	is_player_unit = true

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("scratch", "Scratch", "Team 1", "Team 2")
	attack_component.post_attack_target.connect(_apply_chemical_toxin)

func _set_stats():
	health_component.set_stats(base_health*PlayerData.inner_sanctum.life)
	attack_component.set_stats_absolute(attack_damage*PlayerData.inner_sanctum.power, attack_range, base_critical_percent_chance, base_critical_damage_multiplier)

func _apply_chemical_toxin(targets: Array[Entity], was_crit:bool):
	if was_crit:
		for u in targets:
			if is_instance_valid(u):
				u.effect_component.add_debuff(_construct_chemical_toxin(), self)

func _construct_chemical_toxin() -> ChemicalToxin:
	var mark = ChemicalToxin.new()
	return mark
