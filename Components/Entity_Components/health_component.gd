extends Node2D
class_name  HealthComponent

signal damage_taken(attacker: Entity, is_crit: bool)
signal died(this_unit: Unit)

@onready var parent_entity: Entity = get_parent().get_parent()
@onready var health_bar:  = get_parent().get_parent().get_node_or_null("UIComponents/HealthBar")

@export var max_health: int
@export var current_health: int

var is_alive: bool = true

func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)

func set_stats(set_max_health: int):
	max_health = set_max_health
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health

func take_damage(attacker: Entity):
	current_health -= attacker.attack_component.attack_damage
	current_health = clamp(current_health, 0, max_health)
	health_bar.value = current_health
	damage_taken.emit(attacker)
	if current_health <= 0:
		is_alive = false
		die(attacker)

func take_damage_flat(attacker: Entity, amount: int, is_crit: bool):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	health_bar.value = current_health
	damage_taken.emit(attacker, is_crit)
	if current_health <= 0:
		is_alive = false
		die(attacker)

func heal(amount: int):
	current_health += amount
	current_health = clamp(current_health, 0, max_health)
	health_bar.value = current_health

func die(killer: Unit):
	var parent_entity_tile = BoardGrid.world_to_tile(parent_entity.position)
	BoardGrid.set_tile_solid(parent_entity_tile, false)
	died.emit(parent_entity)
	parent_entity.queue_free()
