extends Node2D
class_name Entity

var id: String
var display_name: String
var hostile_team: String

@onready var attack_component: AttackComponent = get_node_or_null("Components/AttackComponent")
@onready var effect_component: EffectComponent = get_node_or_null("Components/EffectComponent")
@onready var buff_component: BuffComponent = get_node_or_null("Components/BuffComponent")
@onready var health_component: HealthComponent = get_node_or_null("Components/HealthComponent")
@onready var movment_component: MovmentComponent = get_node_or_null("Components/MovmentComponent")
@onready var targeting_component: TargetingComponent = get_node_or_null("Components/TargetingComponent")
@onready var targetable_component: TargetableComponent = get_node_or_null("Components/TargetableComponent")
@onready var weapon_slot_component: WeaponSlotComponent = get_node_or_null("Components/WeaponSlotComponent")
@onready var weapon_component: WeaponComponent = get_node_or_null("Components/WeaponComponent")

@onready var ui_components_health_bar: ProgressBar = get_node_or_null("UIComponents/HealthBar")
@onready var ui_components_weapon_energy_bar: ProgressBar = get_node_or_null("UIComponents/WeaponEnergyProgressBar")
