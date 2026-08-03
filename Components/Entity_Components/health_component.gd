extends Node2D
class_name  HealthComponent

signal pre_damage_taken(attacker: Entity, is_crit: bool)
signal pre_calculate_damage
signal post_calculate_damage
signal damage_taken(attacker: Entity, is_crit: bool)
signal died(this_unit: Unit)
signal pre_heal(target: Entity, amount: int)
signal post_heal(target: Entity, amount: int)

@onready var parent_entity: Entity = get_parent().get_parent()
@onready var health_bar:  = get_parent().get_parent().get_node_or_null("UIComponents/HealthBar")

var is_alive: bool = true
var base_heal_modifier: float = 1.0
var final_heal_modifier: float = 1.0
var base_damage_taken_modifier: float = 1.0
var final_damage_taken_modifier: float = 1.0
var final_damage_taken_amount: int = 0

@export var max_health: int
@export var current_health: int
@export var base_defense: int


func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)

func set_stats(set_max_health: int):
	max_health = set_max_health
	current_health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

func take_damage_flat(attacker: Entity, amount: int, is_crit: bool = false):
	pre_calculate_damage.emit(attacker, amount, is_crit)
	final_damage_taken_modifier = base_damage_taken_modifier
	pre_damage_taken.emit(attacker, amount, is_crit)
	
	final_damage_taken_amount = amount * final_damage_taken_modifier * (1.0 - base_defense / 100.0)
	
	post_calculate_damage.emit(attacker, amount, is_crit)
	current_health -= final_damage_taken_amount
	current_health = clamp(current_health, 0, max_health)
	
	health_bar.value = current_health
	damage_taken.emit(attacker, is_crit)
	if is_instance_valid(self):
		_flash_damage()
		if current_health <= 0:
			die(attacker)

func _flash_damage() -> void:
	var sprite: Sprite2D = parent_entity.get_node_or_null("Sprite2D")
	if sprite == null:
		return
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE

func heal(amount: int):
	final_heal_modifier = base_heal_modifier
	pre_heal.emit(parent_entity, amount)
	current_health += (int(amount * final_heal_modifier))
	current_health = clamp(current_health, 0, max_health)
	health_bar.value = current_health
	post_heal.emit(parent_entity, amount)

func die(_killer: Unit, execute: bool = false):
	if is_alive:
		is_alive = false
		var parent_entity_tile = BoardGrid.world_to_tile(parent_entity.position)
		BoardGrid.set_tile_solid(parent_entity_tile, false)
		died.emit(parent_entity)
		if execute:
			parent_entity.free()
		else:
			parent_entity.queue_free()
