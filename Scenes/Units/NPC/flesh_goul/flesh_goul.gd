extends Unit

@export_category("Stats")
@export var max_health: int = 10
@export var attack_damage: int = 1

func _init() -> void:
	id = "flesh_goul"

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("flesh_goul", "Flesh Goul", "Team 2", "Team 1")

func _set_stats():
	health_component.set_stats(max_health)
