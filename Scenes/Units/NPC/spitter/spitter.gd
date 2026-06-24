extends Unit

func _init() -> void:
	id = "spitter"
	
	base_health = 200
	attack_damage = 10
	attack_range = 250
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("spitter", "Spitter", "Team 2", "Team 1")
	essence_value = [1, PlayerData.dungeon_layer_level]
	attack_component.post_attack_target.connect(_on_attack_target)

func _set_stats():
	health_component.set_stats(get_total_health())
	attack_component.set_stats_absolute(
		get_total_attack_damage(),
		attack_range,
		base_critical_percent_chance,
		base_critical_damage_multiplier)

func _on_attack_target(targets: Array[Entity], _is_crit: bool):
	var debuff = AttackSpeedDown.new(4, 1)
	
	for target in targets:
		target.effect_component.add_debuff(debuff, self)
