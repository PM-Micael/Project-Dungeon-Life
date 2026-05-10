extends Unit

@export_category("Stats")
@export var max_health: int = 100
@export var attack_damage: int = 5

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

func _set_stats():
	health_component.set_stats(max_health)
