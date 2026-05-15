extends Unit

@export_category("Stats")
@export var max_health: int = 200
@export var attack_damage: int = 10
@export var base_critical_percent_chance: int = 0
@export var base_critical_damage_multiplier: float = 1.2

func _init() -> void:
	id = "flesh_goul"

func _ready() -> void:
	var scaling = PlayerData.dungeon_enemy_multiplier
	super._ready()
	_set_stats(scaling)
	_info("flesh_goul", "Flesh Goul", "Team 2", "Team 1")
	essence_value = [1, PlayerData.dungeon_layer_level]

func _set_stats(scaling):
	health_component.set_stats(max_health * scaling)
	attack_component.set_stats_absolute(attack_damage * scaling, 100, base_critical_percent_chance, base_critical_damage_multiplier)
