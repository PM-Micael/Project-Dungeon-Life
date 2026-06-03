extends Node2D
class_name WeaponComponent

signal use_weapon_skill

var star_level: int = 1

var max_weapon_energy: int = 100
var current_weapon_energy: int = 70
var weapon_energy_gained_on_attack: int = 10
var weapon_energy_gained_on_damage_taken: int = 0
var ability_can_crit: bool = false

@export var added_attack_damage_multiplier: int
var weapon_energy_bar: ProgressBar

# Character -> Components -> WeaponSlotComponent -> Weapon -> Components -> WeaponComponent
@onready var entity_holding_weapon: Entity = get_parent().get_parent().get_parent().get_parent().get_parent()

func _ready() -> void:
	# This might not be needed when I start spawning in nodes from config files and database
	await get_tree().process_frame
	
	set_weapon_energy_bar()
	_connect_events()
	set_stats_absolute()

func _connect_events():
	entity_holding_weapon.attack_component.pre_attack_target.connect(_prep_attack)
	entity_holding_weapon.attack_component.post_attack_target.connect(_finish_attack)
	entity_holding_weapon.health_component.damage_taken.connect(_on_damage_taken)

func set_stats_absolute(set_added_damage: int = added_attack_damage_multiplier):
	added_attack_damage_multiplier = set_added_damage * star_level

func set_weapon_energy_bar():
		weapon_energy_bar = entity_holding_weapon.ui_components_weapon_energy_bar
		
		weapon_energy_bar.max_value = max_weapon_energy
		weapon_energy_bar.value = current_weapon_energy

func _on_damage_taken(attacker, is_crit):
	adjust_energy([])

func _prep_attack(target: Entity):
	entity_holding_weapon.attack_component.weapon_added_multiplier += added_attack_damage_multiplier

func _finish_attack(targets: Array[Entity], is_crit: bool):
	adjust_energy(targets)
	entity_holding_weapon.attack_component.weapon_added_multiplier -= added_attack_damage_multiplier

func adjust_energy(targets: Array[Entity]):
	current_weapon_energy += weapon_energy_gained_on_attack # Changing both bar and value might be conveluted
	if current_weapon_energy >= max_weapon_energy:
		use_weapon_skill.emit(targets)
		current_weapon_energy = 0
		
	weapon_energy_bar.value = current_weapon_energy

func get_total_damage() -> int:
	return (added_attack_damage_multiplier*star_level)
