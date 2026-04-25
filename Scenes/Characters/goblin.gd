extends Unit

@export_category("Stats")
@export var max_health: int = 10

func _init() -> void:
	id = "unit_goblin"

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("goblin", "Goblin", "Team 1", "Team 2")

func _set_stats():
	health_component.set_stats(max_health)
