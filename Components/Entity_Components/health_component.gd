extends Node2D
class_name  HealthComponent

signal pre_damage_taken(attacker: Entity, is_crit: bool)
signal pre_calculate_damage
signal post_calculate_damage
signal damage_taken(attacker: Entity, is_crit: bool)
signal health_changed(current: int, maximum: int)
signal died(this_unit: Unit)
signal pre_heal(target: Entity, amount: int)
signal post_heal(target: Entity, amount: int)

# Lazy getters, not @onready: stats are applied at instantiate() while the entity is
# still detached, and @onready vars are null until the node enters the tree.
var parent_entity: Entity:
	get:
		return get_parent().get_parent() as Entity

var health_bar: ProgressBar:
	get:
		return get_parent().get_parent().get_node_or_null("UIComponents/HealthBar")

var defense_node: Control:
	get:
		return get_parent().get_parent().get_node_or_null("UIComponents/Defense")

var defense_value_label: Label:
	get:
		return get_parent().get_parent().get_node_or_null("UIComponents/Defense/DefenseValueLabel")

var is_alive: bool = true
var base_heal_modifier: float = 1.0
var final_heal_modifier: float = 1.0
var base_damage_taken_modifier: float = 1.0
var final_damage_taken_modifier: float = 1.0
var final_damage_taken_amount: int = 0

@export var max_health: int
@export var current_health: int
@export var base_defense: int = 0
@export var defense: int

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)

func set_stats(set_max_health: int, set_defense: int = 0):
	max_health = set_max_health
	base_defense = set_defense
	defense = set_defense
	if health_bar:
		health_bar.max_value = max_health
	_set_health(max_health)

	_set_defense(defense)

## The single place current_health changes. Keeps the health bar and any listening
## UI in sync, and is safe to call while the entity is detached from the tree.
func _set_health(value: int):
	current_health = clamp(value, 0, max_health)
	if health_bar:
		health_bar.value = current_health
	health_changed.emit(current_health, max_health)

func _set_defense(defense: int):
	if defense_node:
		if defense == 0:
			defense_node.visible = false
		else:
			defense_value_label.text = str(defense)
			defense_node.visible = true

func take_damage_flat(
	attacker: Entity,
	amount: int,
	is_crit: bool = false,
	is_strike: bool = true
	):
	pre_calculate_damage.emit(attacker, amount, is_crit)
	final_damage_taken_modifier = base_damage_taken_modifier
	pre_damage_taken.emit(attacker, amount, is_crit)
	
	final_damage_taken_amount = amount * final_damage_taken_modifier * (1.0 - defense / 100.0)
	
	post_calculate_damage.emit(attacker, amount, is_crit)
	_set_health(current_health - final_damage_taken_amount)

	damage_taken.emit(attacker, is_crit)
	if is_instance_valid(self):
		if is_strike:
			_damage_effect(attacker.attack_component.attack_sprite_scene)
		else:
			_damage_effect({})
		if current_health <= 0:
			die(attacker)

func _damage_effect(vfx_dict: Dictionary = {}) -> void:
	if not vfx_dict.is_empty():
		var vfx_scene: PackedScene = vfx_dict["path"]
		var vfx_animation: String = vfx_dict["animation"]
		var vfx = vfx_scene.instantiate()
		vfx.scale = vfx_dict["scale"]
		add_child(vfx)
		vfx.play(vfx_animation)
		vfx.animation_finished.connect(_on_animation_finished.bind(vfx))
	
	_flash_damage()

func _flash_damage() -> void:
	var sprite: Sprite2D = parent_entity.get_node_or_null("Sprite2D")
	if sprite == null:
		return
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE

func _on_animation_finished(vfx: AnimatedSprite2D):
	vfx.queue_free()

func heal(amount: int):
	final_heal_modifier = base_heal_modifier
	pre_heal.emit(parent_entity, amount)
	_set_health(current_health + int(amount * final_heal_modifier))
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
