extends Unit

@export_category("Stats")
@export var max_health: int = 10
@export var attack_damage: int = 1
@export var base_critical_percent_chance: int = 15
@export var base_critical_damage_multiplier: float = 1.6

func _init() -> void:
	id = "unit_skeleton"

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("skeleton", "Skeleton", "Team 2", "Team 1")

func _set_stats():
	health_component.set_stats(max_health)
	attack_component.set_stats_absolute(attack_damage, 100, base_critical_percent_chance, base_critical_damage_multiplier)
