extends Node2D
class_name Entity

var id: String
var display_name: String
var hostile_team: String

@onready var attack_component: AttackComponent = get_node_or_null("Components/AttackComponent")
@onready var debuff_component: DebuffComponent = get_node_or_null("Components/DebuffComponent")
@onready var buff_component: BuffComponent = get_node_or_null("Components/BuffComponent")
@onready var health_component: HealthComponent = get_node_or_null("Components/HealthComponent")
@onready var movment_component: MovmentComponent = get_node_or_null("Components/MovmentComponent")
@onready var targeting_component: TargetingComponent = get_node_or_null("Components/TargetingComponent")
@onready var targetable_component: TargetableComponent = get_node_or_null("Components/TargetableComponent")
@onready var weapon_slot_component: WeaponSlotComponent = get_node_or_null("Components/WeaponSlotComponent")
@onready var weapon_component: WeaponComponent = get_node_or_null("Components/WeaponComponent")

@onready var ui_components_health_bar: ProgressBar = get_node_or_null("UIComponents/HealthBar")
@onready var ui_components_weapon_energy_bar: ProgressBar = get_node_or_null("UIComponents/WeaponEnergyProgressBar")

func _physics_process(_delta: float) -> void:
	_action()

func _action():
	targeting_component_action()
	movment_component_action()
	attack_component_action()

func targeting_component_action():
	if targeting_component != null:
			targeting_component.select_closest_target(hostile_team)

func movment_component_action():
	if movment_component != null:
		if (movment_component.timer.time_left <= 0.1 and
		targeting_component != null and 
		targeting_component.target != null
		):
			if attack_component != null:
				attack_component.in_target_attack_range = movment_component.move_to_target_tile(targeting_component.target)
				movment_component.timer.start()
		
		return
		if (movment_component.timer.time_left <= 0.1 &&
		(targeting_component != null &&
		targeting_component.target != null)
		):
			if(attack_component != null):
				attack_component.in_target_attack_range = movment_component.move_to_target(targeting_component.target) # Set attack range
			else:
				movment_component.move_to_grid()
				movment_component.move_to_target(targeting_component.target)
			movment_component.timer.start()

func attack_component_action(): # perhaps more efficient if statment can be implimented
	if attack_component != null:
		if (attack_component.in_target_attack_range &&
		attack_component.timer.time_left <= 0.1 &&
		(targeting_component != null &&
		targeting_component.target != null)):
			attack_component.attack_target(targeting_component.target)
			attack_component.timer.start()
