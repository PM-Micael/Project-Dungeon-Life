extends Unit

func _init() -> void:
	id = "flesh_goul"
	
	base_health = 200
	attack_damage = 10
	attack_range = 100
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("flesh_goul", "Flesh Goul", "Team 2", "Team 1")
	essence_value = [1, PlayerData.dungeon_layer_level]

func _set_stats():
	health_component.set_stats(get_total_health())
	attack_component.set_stats_absolute(
		get_total_attack_damage(),
		attack_range,
		base_critical_percent_chance,
		base_critical_damage_multiplier)
