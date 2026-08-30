extends Node2D
class_name Entity

var id: String
var display_name: String
var hostile_team: String

var attack_component: AttackComponent:
	get:
		return get_node_or_null("Components/AttackComponent")

var effect_component: EffectComponent:
	get:
		return get_node_or_null("Components/EffectComponent")
	
var health_component: HealthComponent:
	get:
		return get_node_or_null("Components/HealthComponent")
	
var movment_component: MovmentComponent:
	get:
		return get_node_or_null("Components/MovmentComponent")

var targeting_component: TargetingComponent:
	get:
		return get_node_or_null("Components/TargetingComponent")

var targetable_component: TargetableComponent:
	get:
		return get_node_or_null("Components/TargetableComponent")

var weapon_slot_component: WeaponSlotComponent:
	get:
		return get_node_or_null("Components/WeaponSlotComponent")

var weapon_component: WeaponComponent:
	get:
		return get_node_or_null("Components/WeaponComponent")

@onready var ui_components_health_bar: ProgressBar = get_node_or_null("UIComponents/HealthBar")
@onready var ui_components_weapon_energy_bar: ProgressBar = get_node_or_null("UIComponents/WeaponEnergyProgressBar")
@onready var ui_component: UIComponents = $UIComponents
