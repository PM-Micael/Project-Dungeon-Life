extends Node2D
class_name AttackComponent

signal pre_attack_target
signal post_attack_target

@export var attack_damage: int = 1
@export var attack_range: int = 100
@export var base_critical_percent_chance: int = 0
@export var base_critical_damage_multiplier: float = 1.0

var weapon_added_multiplier: int = 0
var is_crit = false

@onready var entity_parent: Entity = get_parent().get_parent()
@onready var timer: Timer = $Timer

var in_target_attack_range: bool = false

func set_stats_absolute(set_attack_damage: int, set_attack_range: int, set_crit_chance: int, set_crit_damage):
	attack_damage = set_attack_damage
	attack_range = set_attack_range
	base_critical_percent_chance = set_crit_chance
	base_critical_damage_multiplier = set_crit_damage

func attack_target(target: Entity):
	pre_attack_target.emit(target)
	is_crit = roll_crit()
	
	var target_health_bar: HealthComponent = target.health_component
	if target_health_bar != null:
		target_health_bar.take_damage_flat(entity_parent, get_total_attack_damage(is_crit), is_crit)
	
	var targets: Array[Entity] = [target]
	post_attack_target.emit(targets, is_crit)

func roll_crit() -> bool:
	var crit_roll = randi_range(0, 100)
	if crit_roll <= base_critical_percent_chance:
		return true
	return false

func get_total_attack_damage(is_crit: bool) -> int:
	if is_crit:
		return (attack_damage + weapon_added_multiplier) * base_critical_damage_multiplier
	return attack_damage + weapon_added_multiplier
