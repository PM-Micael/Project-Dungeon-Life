extends Unit

var skill_cooldown: float = 4.0

func _init() -> void:
	id = "magma_blob"
	is_boss = true
	base_health = 1000
	attack_damage = 10
	attack_range = 1000
	base_defense = 0
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("magma_blob", "Magma Blob", "Team 2", "Team 1")
	essence_value = [3, PlayerData.dungeon_layer_level*3]
	targeting_component.select_all_targets("Team 1")

func _physics_process(delta: float) -> void:
	for effect in effect_component.active_blessings:
		if effect is MoltenDisaster:
			return
	
	skill_cooldown -= delta
	if skill_cooldown <= 0:
		var effect = MoltenDisaster.new()
		effect_component.add_effect(
			effect,
			self,
			effect_component.active_blessings
			)
		skill_cooldown = 4.0

func _set_stats():
	health_component.set_stats(get_total_health(), base_defense)
	attack_component.set_stats_absolute(
		get_total_attack_damage(),
		attack_range,
		base_critical_percent_chance,
		base_critical_damage_multiplier
		)
	attack_component.attack_speed = 1.6
