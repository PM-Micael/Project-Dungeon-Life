extends Unit

@export_category("Stats") 
@export var max_health: int = 1800 * PlayerData.dungeon_difficulty_multiplier
@export var attack_damage: int = 90 * PlayerData.dungeon_difficulty_multiplier
@export var base_critical_percent_chance: int = 0
@export var base_critical_damage_multiplier: float = 1.2

func _init() -> void:
	id = "flesh_hulk"

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("flesh_hulk", "Flesh Hulk", "Team 2", "Team 1")
	essence_value = [9*PlayerData.dungeon_difficulty_multiplier, 18*PlayerData.dungeon_difficulty_multiplier]

func _set_stats():
	health_component.set_stats(max_health)
	attack_component.set_stats_absolute(attack_damage, 100, base_critical_percent_chance, base_critical_damage_multiplier)
