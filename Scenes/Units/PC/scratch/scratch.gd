extends Unit

func _init() -> void:
	id = "scratch"
	passive_description = "Weak point oppertunist: Crits grant a stack of"
	base_health = 100
	attack_damage = 20
	attack_range = 250
	base_critical_percent_chance = 15
	base_critical_damage_multiplier = 1.3
	is_player_unit = true

func _ready() -> void:
	super._ready()
	_info("scratch", "Scratch", "Team 1", "Team 2")
	attack_component.post_attack_targets.connect(_on_post_attack)

func _set_stats() -> void:
	health_component.set_stats(base_health*PlayerData.inner_sanctum.life, base_defense)
	attack_component.set_stats_absolute(attack_damage*PlayerData.inner_sanctum.power, attack_range, base_critical_percent_chance, base_critical_damage_multiplier)

func _on_post_attack(_targets: Array[Entity], was_crit:bool):
	_consume_weak_point_opportunist_stack()
	if was_crit:
		_apply_weak_point_opportunist()

func _apply_weak_point_opportunist():
	for existing in effect_component.active_blessings:
		if existing.id == "weak_point_opportunist":
			existing.apply(self)
			return
	
	var blessing = WeakPointOpportunist.new()
	effect_component.add_effect(blessing, self, effect_component.active_blessings)

func _consume_weak_point_opportunist_stack():
	for blessing in effect_component.active_blessings:
		if blessing.id == "weak_point_opportunist":
			blessing.consume_stack()
			if blessing.stacks <= 0:
				effect_component.active_blessings.erase(blessing)
			return
