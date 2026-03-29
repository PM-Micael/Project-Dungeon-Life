extends Node2D
class_name WeaponSlotComponent

@onready var weapon: Entity = get_child(0)

func _ready() -> void:
	if (weapon != null) and (weapon.weapon_component != null):
		print("Has weapon")
	elif weapon == null:
		print("Has no Weapon")
	elif weapon.weapon_component == null:
		print("No weapon in weapon slot.")
