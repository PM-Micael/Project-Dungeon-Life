extends Unit

@export_category("Stats")
@export var max_health: int = 100

func _init() -> void:
	id = "unit_skeleton"

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("skeleton", "Skeleton", "Team 2", "Team 1")

func _set_stats():
	health_component.set_stats(max_health)
