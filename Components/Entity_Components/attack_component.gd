extends Node2D
class_name AttackComponent

signal pre_attack_target
signal post_attack_target

@export var attack_damage: int = 1
@export var attack_range: int = 100

var weapon_added_multiplier: int = 0

@onready var entity_parent: Entity = get_parent().get_parent()
@onready var timer: Timer = $Timer

var in_target_attack_range: bool = false

func set_stats_absolute(set_attack_damage: int, set_attack_range: int):
	attack_damage = set_attack_damage
	attack_range = set_attack_range

func attack_target(target: Entity):
	pre_attack_target.emit(target)
	
	var target_health_bar: HealthComponent = target.health_component
	if target_health_bar != null:
		target_health_bar.take_damage_flat(entity_parent, get_total_attack_damage())
	
	var targets: Array[Entity] = [target]
	post_attack_target.emit(targets)

func get_total_attack_damage() -> int:
	return attack_damage + weapon_added_multiplier
