extends CharacterBody2D
class_name Entity

var enetity_name: String
var hostile_group_is: String

@export_category("Node Refferences")
@onready var health_bar: ProgressBar = $Components/HealthComponent/HealthBar

@export_category("Stats")
@export var attack: int = 1

@export_category("Other")
@export var starting_position: Vector2

func _ready() -> void:
	position = starting_position
	
	var timer = get_node("/root/Game/Board/Timer")
	timer.action_tick.connect(entity_action)

func entity_action():
	_choose_target(hostile_group_is)

func _choose_target(target_group: String):
	var enemies = get_tree().get_nodes_in_group(target_group)
	if enemies.is_empty():
		return
	
	var closest_enemy = enemies[0]
	
	for e in enemies:
		if global_position.distance_to(e.global_position) < global_position.distance_to(closest_enemy.global_position):
			closest_enemy = e
	
	_move_to_target(closest_enemy)

func _move_to_target(target):
	var delta = target.global_position - global_position
	
	if (abs(delta.y) == 0 && abs(delta.x) == 100) || (abs(delta.x) == 0 && abs(delta.y) == 100):
		_attack_target(target)
	else:
		if abs(delta.y) > abs(delta.x):
			global_position.y += sign(delta.y) * 100
		else:
			global_position.x += sign(delta.x) * 100

func _attack_target(target: Entity):
	var target_health_bar: HealthBarComponent = target.get_node("Components/HealthComponent/HealthBar")
	target_health_bar.take_damage(self)
