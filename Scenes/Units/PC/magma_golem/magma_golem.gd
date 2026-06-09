extends Unit

var molten_core_active: bool = false

func _init() -> void:
	id = "magma_golem"
	passive_description = "Magma Golem starts the battle shielded by Molten Layer.
		When the shield is broken, his molten core is exposed —
		any attacker who strikes him will be set Burning."
	base_health = 400
	attack_damage = 10
	attack_range = 100
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.0
	is_player_unit = true

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("magma_golem", "Magma Golem", "Team 1", "Team 2")
	_apply_molten_layer()
	health_component.damage_taken.connect(_on_damage_taken)

func _set_stats() -> void:
	health_component.set_stats(base_health * PlayerData.inner_sanctum.life)
	attack_component.set_stats_absolute(attack_damage * PlayerData.inner_sanctum.power, attack_range, base_critical_percent_chance, base_critical_damage_multiplier)

func _apply_molten_layer() -> void:
	var blessing = MoltenLayer.new()
	effect_component.add_blessing(blessing, self)

# Called by MoltenLayer when the shield breaks
func _on_molten_layer_broken() -> void:
	molten_core_active = true

func _on_damage_taken(attacker: Entity, _is_crit: bool) -> void:
	if molten_core_active:
		if is_instance_valid(attacker) and not attacker.effect_component == null:
			attacker.effect_component.add_debuff(_construct_burning(), self)

func _construct_burning() -> Burning:
	return Burning.new()
