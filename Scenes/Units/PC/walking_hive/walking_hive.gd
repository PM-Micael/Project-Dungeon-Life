extends Unit

@export_category("Stats")
@export var base_health: int = 15
@export var attack_damage: int = 1
@export var base_critical_percent_chance: int = 15
@export var base_critical_damage_multiplier: float = 1.65

@export_category("Effects")
@export var unity_count: int = 0

func _init() -> void:
	id = "walking_hive"
	passive_description = "Dealing critical damage applies chmical toxin to target hit.
		Chemical toxin deals damage every second to the target."

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("walking_hive", "Walking Hive", "Team 1", "Team 2")
	unity_count = _check_unity_in_battle()
	_connect_blood_flies()

func _set_stats():
	health_component.set_stats(base_health * PlayerData.inner_sanctum.life)
	attack_component.set_stats_absolute(attack_damage, 200, base_critical_percent_chance, base_critical_damage_multiplier)

func _connect_blood_flies():
	var enemy_units_node = get_node("/root/TeamLineupMenu/Board/Units/EnemyUnits")
	enemy_units_node.child_entered_tree.connect(_apply_blood_flies)

func _apply_blood_flies(unit: Node):
	await unit.ready
	unit.effect_component.add_affliction(BloodFlies.new(), self)
	print(self.display_name+" applied blood flies to "+unit.name)
	return
	
