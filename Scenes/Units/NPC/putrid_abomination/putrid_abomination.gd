extends Unit

@export_category("Stats")
@export var max_health: int = 8000 * PlayerData.dungeon_layer_level
@export var attack_damage: int = 150 * PlayerData.dungeon_layer_level
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

func _set_stats():
	health_component.set_stats(max_health)
	attack_component.set_stats_absolute(attack_damage, 100, base_critical_percent_chance, base_critical_damage_multiplier)
	attack_component.attack_speed = 1.6
