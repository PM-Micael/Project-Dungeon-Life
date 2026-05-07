extends Unit

@export_category("Stats")
@export var base_health: int = 200
@export var attack_damage: int = 2
@export var base_critical_percent_chance: int = 15
@export var base_critical_damage_multiplier: float = 1.6

var devour_stacks: int = 0

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
	# Connect to damage by weapon skill

func _set_stats():
	health_component.set_stats(base_health * PlayerData.inner_sanctum.life)
	attack_component.set_stats_absolute(attack_damage, 100, base_critical_percent_chance, base_critical_damage_multiplier)

func _apply_devour_debuff(targets: Array[Entity]):
	for u in targets:
		u.debuff_component.add_debuff(_construct_devour_mark_debuff(), self)

func _construct_devour_mark_debuff() -> DevourersMark:
	var mark = DevourersMark.new()
	
	return mark
