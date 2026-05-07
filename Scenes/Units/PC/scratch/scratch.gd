extends Unit

@export_category("Stats")
@export var base_health: int = 10
@export var attack_damage: int = 2
@export var base_critical_percent_chance: int = 15
@export var base_critical_damage_multiplier: float = 1.65

func _init() -> void:
	id = "scratch"
	passive_description = "Dealing critical damage applies chmical toxin to target hit.
		Chemical toxin deals damage every second to the target."

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("scratch", "Scratch", "Team 1", "Team 2")
	attack_component.post_attack_target.connect(_apply_chemical_toxin)

func _set_stats():
	health_component.set_stats(base_health * PlayerData.inner_sanctum.life)
	attack_component.set_stats_absolute(attack_damage, 200, base_critical_percent_chance, base_critical_damage_multiplier)

func _apply_chemical_toxin(targets: Array[Entity], was_crit:bool):
	if was_crit:
		for u in targets:
			u.debuff_component.add_debuff(_construct_chemical_toxin(), self)

func _construct_chemical_toxin() -> ChemicalToxin:
	var mark = ChemicalToxin.new()
	return mark
