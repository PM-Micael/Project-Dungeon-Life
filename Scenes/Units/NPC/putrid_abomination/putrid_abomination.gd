extends Unit

@export_category("Stats")
@export var max_health: int = 1000
@export var attack_damage: int = 50
@export var base_critical_percent_chance: int = 0
@export var base_critical_damage_multiplier: float = 1.2

func _init() -> void:
	id = "putrid_abomination"

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
	health_component.set_stats(max_health * scaling)
	attack_component.set_stats_absolute(attack_damage * scaling, 100, base_critical_percent_chance, base_critical_damage_multiplier)
	attack_component.attack_speed = 1.6
