extends Unit

func _init() -> void:
	id = "scratch"
	passive_description = "Weak point oppertunist: Crits grant a stack of"
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
	attack_component.post_attack_target.connect(_on_post_attack)

func _set_stats():
	health_component.set_stats(base_health*PlayerData.inner_sanctum.life)
	attack_component.set_stats_absolute(attack_damage*PlayerData.inner_sanctum.power, attack_range, base_critical_percent_chance, base_critical_damage_multiplier)

func _on_post_attack(_targets: Array[Entity], was_crit:bool):
	_consume_feral_instinct_stack()
	if was_crit:
		_apply_weak_point_opportunist()

func _apply_weak_point_opportunist():
	for existing in effect_component.active_blessings:
		if existing.id == "weak_point_opportunist":
			existing.apply(self)
			return
	
	var blessing = WeakPointOpportunist.new()
	effect_component.add_blessing(blessing, self)

func _consume_feral_instinct_stack():
	for blessing in effect_component.active_blessings:
		if blessing.id == "feral_instinct":
			blessing.consume_stack()
			# Remove blessing entirely if no stacks remain
			if blessing.buffs.size() == 0:
				effect_component.active_blessings.erase(blessing)
			return
