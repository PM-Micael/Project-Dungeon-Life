extends Unit

@export_category("Info")

@export_category("Stats")
@export var max_health: int = 20

func _init() -> void:
	id = "unit_zac"
	passive_description = "Dealing damage to an enemy marks them.
	Dealing damage to a marked enemy with 5% or less executes them and grants Zac a stack of Devour.
	Each stack of devour grants plus 1 max heaelth"

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("zac", "Zac", "Team 1", "Team 2")
	attack_component.post_attack_target.connect(_apply_devour_debuff)

func _set_stats():
	health_component.set_stats(max_health)

func _apply_devour_debuff(targets: Array[Entity]):
	print("Devour")
