extends Node2D
class_name WeaponComponent

var max_weapon_energy: int = 100
var current_weapon_energy: int = 70
var weapon_energy_gained_on_attack: int = 10

var added_attack_damage_multiplier: int

# Character -> Components -> WeaponSlotComponent -> Weapon -> Components -> WeaponComponent
@onready var entity_holding_weapon: Entity = get_parent().get_parent().get_parent().get_parent().get_parent()

func _ready() -> void:
	# This might not be needed when I start spawning in nodes from config files and database
	await get_tree().process_frame
	
	entity_holding_weapon.attack_component.pre_attack_target.connect(_prep_attack)
	entity_holding_weapon.attack_component.post_attack_target.connect(_finish_attack)

func _prep_attack():
	entity_holding_weapon.attack_component.weapon_added_multiplier += added_attack_damage_multiplier

func _finish_attack():
	adjust_energy()
	entity_holding_weapon.attack_component.weapon_added_multiplier -= added_attack_damage_multiplier

func adjust_energy():
	current_weapon_energy += weapon_energy_gained_on_attack
	print("Weapon energy at: " + str(current_weapon_energy) + "/" + str(max_weapon_energy))
	if current_weapon_energy >= max_weapon_energy:
		_weapon_skill()
		current_weapon_energy = 0

func _weapon_skill():
	print("Using [weapon_skill]")
