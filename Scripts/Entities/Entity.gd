extends CharacterBody2D
class_name Entity

@export_category("Stats")
@export var max_health: int = 10
@export var attack_damage: int = 1
@export var attack_range: int = 100
@export var movment_timer: float = 1.1

@onready var health_bar: HealthBarComponent = get_node_or_null("Components/HealthComponent/HealthBar")
@onready var movment_component: MovmentComponent = get_node_or_null("Components/MovmentComponent")
@onready var attack_component: AttackComponent = get_node_or_null("Components/AttackComponent")
@onready var targeting_component: TargetingComponent = get_node_or_null("Components/TargetingComponent")
@onready var targetable_component: TargetableComponent = get_node_or_null("Components/TargetableComponent")

var hostile_team: String

@export_category("Other")
@export var starting_position: Vector2

func _ready() -> void:
	position = starting_position
	_set_stats()

func _set_stats():
	if health_bar != null:
		health_bar.max_health = max_health
	if movment_component != null:
		movment_component.timer.wait_time = movment_timer
	if attack_component != null:
		attack_component.attack_damage = attack_damage
		attack_component.attack_range = attack_range

func _physics_process(_delta: float) -> void:
	_action()

func _action():
	targeting_component_action()
	movment_component_action()
	attack_component_action()

func targeting_component_action():
	if targeting_component != null:
			targeting_component.select_target(hostile_team)

func movment_component_action():
	if movment_component != null:
		if movment_component.timer.time_left <= 0.1 && targeting_component.target != null:
			if(attack_component != null):
				attack_component.in_target_attack_range = movment_component.move_to_target(targeting_component.target) # Set attack range
			else:
				movment_component.move_to_target(targeting_component.target)
			movment_component.timer.start()

func attack_component_action():
	if attack_component != null:
		if attack_component.in_target_attack_range && attack_component.timer.time_left <= 0.1 && targeting_component.target != null:
			attack_component.attack_target(targeting_component.target)
			attack_component.timer.start()
