extends Unit

var molten_core_active: bool = false

func _init() -> void:
	id = "magnus"
	passive_description = "Magnus starts the battle shielded by Molten Layer.
		When the shield is broken, his molten core is exposed.
		Any attacker who strikes him will be set Burning."
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
	var shield = Shield.new(0, 1000)
	effect_component.add_effect(shield, self, effect_component.active_blessings)

func _on_damage_taken(attacker: Entity, _is_crit: bool) -> void:	
	if not effect_component.active_buffs.has(Shield):
		if is_instance_valid(attacker) and not attacker.effect_component == null:
			attacker.effect_component.add_effect(_construct_burning(), self, attacker.effect_component.active_debuffs)

func _construct_burning() -> Burning:
	return Burning.new()
