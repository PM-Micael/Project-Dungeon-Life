extends Unit

@export_category("Stats")
@export var max_health: int = 200
@export var attack_damage: int = 20
@export var base_critical_percent_chance: int = 0
@export var base_critical_damage_multiplier: float = 1.2

func _init() -> void:
	id = "flesh_tendrill"

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("flesh_tendrill", "Flesh Tendrill", "Team 2", "Team 1")

func _set_stats():
	health_component.set_stats(max_health)
	attack_component.set_stats_absolute(attack_damage, 200, base_critical_percent_chance, base_critical_damage_multiplier)
