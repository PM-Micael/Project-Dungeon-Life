extends Node2D
class_name WeaponComponent

var max_weapon_energy: int
var current_energy: int
var energy_gained_on_attack: int

@onready var parent_entity: Entity = get_parent().get_parent()
