extends Unit

func _init() -> void:
	id = "putrid_abomination"
	base_health = 1000
	attack_damage = 50
	attack_range = 100
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("putrid_abomination", "Putrid Abomination", "Team 2", "Team 1")
	_apply_flesh_shield()

func _apply_flesh_shield():
	var flesh_shield = FleshShield.new()
	effect_component.add_blessing(flesh_shield, self)
	essence_value = [5, 10]

func _set_stats():
	var scaling = PlayerData.dungeon_enemy_multiplier
	health_component.set_stats(get_total_health())
	attack_component.set_stats_absolute(get_total_attack_damage(), 100, base_critical_percent_chance, base_critical_damage_multiplier)
	attack_component.attack_speed = 1.6
