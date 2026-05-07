extends Unit

@export_category("Stats")
@export var max_health: int = 30
@export var attack_damage: int = 3

func _init() -> void:
	id = "flesh_hulk"

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("flesh_hulk", "Flesh Hulk", "Team 2", "Team 1")

func _set_stats():
	health_component.set_stats(max_health)
