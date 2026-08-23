extends Unit


func _init() -> void:
	id = "magnus"
	passive_description = "Starts every round with a shield.
	When Magnus is atacked while not under a shild, aplies Burning on the attacker."
	base_health = 400
	attack_damage = 10
	attack_range = 100
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.0
	is_player_unit = true

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("magnus", "Magnus", "Team 1", "Team 2")
	_apply_shield()
	health_component.damage_taken.connect(_on_damage_taken)

func _set_stats() -> void:
	health_component.set_stats(base_health * PlayerData.inner_sanctum.life)
	attack_component.set_stats_absolute(attack_damage * PlayerData.inner_sanctum.power, attack_range, base_critical_percent_chance, base_critical_damage_multiplier)

func _apply_shield() -> void:
	var shield = Shield.new(0, 0.5)
	effect_component.add_effect(shield, self, effect_component.active_buffs)

func _on_damage_taken(attacker: Entity, _is_crit: bool) -> void:
	for buff in effect_component.active_buffs:
		if buff is Shield:
			return
		
	if is_instance_valid(attacker) and not attacker.effect_component == null:
		attacker.effect_component.add_effect(_construct_burning(), self, attacker.effect_component.active_debuffs)

func _construct_burning() -> Burning:
	return Burning.new()
