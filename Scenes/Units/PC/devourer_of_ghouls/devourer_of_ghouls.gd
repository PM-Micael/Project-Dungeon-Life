extends Unit

var devour_stacks: int = 0

func _init() -> void:
	id = "devourer_of_ghouls"
	passive_description = "Dealing damage to an enemy marks them.
		Dealing damage to a marked enemy with 5% or less executes them and grants Devourer Of Ghouls a stack of Devour.
		Each stack of devour grants plus 1 max health"
	base_health = 400
	attack_damage = 10
	attack_range = 100
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2
	is_player_unit = true

func _ready() -> void:
	super._ready()
	_info("devourer_of_ghouls", "Devourer Of Ghouls", "Team 1", "Team 2")
	attack_component.post_attack_target.connect(_apply_devour_debuff)
	# Connect to damage by weapon skill

func _set_stats() -> void:
	health_component.set_stats(get_total_health())
	attack_component.set_stats_absolute(get_total_attack_damage(), attack_range, base_critical_percent_chance, base_critical_damage_multiplier)

func _apply_devour_debuff(targets: Array[Entity], _is_crit: bool):
	for u in targets:
		if not u == null:
			if u.effect_component != null:
				u.effect_component.add_effect(_construct_devour_mark_debuff(), self, u.effect_component.active_afflictions)

func _construct_devour_mark_debuff() -> DevourersMark:
	var mark = DevourersMark.new()
	return mark
