extends Node2D
class_name AttackComponent

@onready var entity_parent: Entity = get_parent().get_parent()
@onready var timer: Timer = $Timer
@export var attack_damage: int
@export var attack_range: int

var in_target_attack_range: bool = true

func attack_target(target: Entity):
	var target_health_bar: HealthBarComponent = target.get_node_or_null("Components/HealthComponent/HealthBar")
	if target_health_bar != null:
		target_health_bar.take_damage(entity_parent)
