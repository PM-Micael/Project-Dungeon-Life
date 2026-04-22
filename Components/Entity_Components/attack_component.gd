extends Node2D
class_name AttackComponent

signal pre_attack_target
signal post_attack_target

@export var attack_damage: int = 1
@export var attack_range: int = 100

var weapon_added_multiplier: int = 0

@onready var entity_parent: Entity = get_parent().get_parent()
@onready var timer: Timer = $Timer


var in_target_attack_range: bool = true

func attack_target(target: Entity):
	pre_attack_target.emit()
	
	var target_health_bar: HealthComponent = target.health_component
	if target_health_bar != null:
		target_health_bar.take_damage(entity_parent)
	
	post_attack_target.emit()
