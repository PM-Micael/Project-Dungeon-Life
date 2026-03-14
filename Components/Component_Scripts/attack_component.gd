extends Node2D
class_name AttackComponent

@onready var entity_parent: Entity = get_parent().get_parent()
@onready var timer: Timer = $Timer
@export var attack: int = 1

func attack_target(target: Entity):
	var target_health_bar: HealthBarComponent = target.get_node("Components/HealthComponent/HealthBar")
	target_health_bar.take_damage(entity_parent)
