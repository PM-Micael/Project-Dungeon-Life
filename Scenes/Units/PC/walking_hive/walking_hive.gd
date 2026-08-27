extends Unit

@export_category("Effects")
@export var unity_count: int = 0

func _init() -> void:
	id = "walking_hive"
	passive_description = "Dealing critical damage applies chmical toxin to target hit.
		Chemical toxin deals damage every second to the target."
	base_health = 150
	attack_damage = 10
	attack_range = 200
	base_critical_percent_chance = 15
	base_critical_damage_multiplier = 1.3
	is_player_unit = true

func _ready() -> void:
	super._ready()
	_info("walking_hive", "Walking Hive", "Team 1", "Team 2")
	is_player_unit = true
	unity_count = _check_unity_in_battle()
	_connect_blood_flies()

func _set_stats() -> void:
	health_component.set_stats(get_total_health())
	attack_component.set_stats_absolute(get_total_attack_damage(), attack_range, base_critical_percent_chance, base_critical_damage_multiplier)

func _connect_blood_flies():
	var enemy_units_node = get_node("//root/MainClient/RunManager/BoardWindow/Board/Units/EnemyUnits")
	enemy_units_node.child_entered_tree.connect(_apply_blood_flies)

func _apply_blood_flies(unit: Node):
	await unit.ready
	if not unit.has_method("get") or not "effect_component" in unit:
		return
	if unit.effect_component != null:
		unit.effect_component.add_effect(BloodFlies.new(), self, effect_component.active_afflictions)
