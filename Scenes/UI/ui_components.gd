extends Control
class_name UIComponents

@onready var health_bar: ProgressBar = get_node_or_null("HealthBar")
@onready var weapon_energy_bar: ProgressBar = get_node_or_null("WeaponEnergyProgressBar")
@onready var defense_value_label: Label = $DefenseValueLabel
@onready var shield_bar: ProgressBar = $ShieldBar
@onready var channel_bar: ProgressBar = $Channel/ChannelBar
@onready var channel_title: Label = $Channel/ChannelTitle
