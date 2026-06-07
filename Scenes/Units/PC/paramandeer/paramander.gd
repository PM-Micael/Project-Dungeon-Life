extends Unit

func _init() -> void:
	id = "paramander"
	passive_description = "Breath fire in a cone in front of Paramander wheen he uses his weapon skill."
	base_health = 100
	attack_damage = 10
	attack_range = 200
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2
	is_player_unit = true

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("scratch", "Scratch", "Team 1", "Team 2")

func _set_stats():
	health_component.set_stats(base_health*PlayerData.inner_sanctum.life)
	attack_component.set_stats_absolute(attack_damage*PlayerData.inner_sanctum.power, attack_range, base_critical_percent_chance, base_critical_damage_multiplier)
