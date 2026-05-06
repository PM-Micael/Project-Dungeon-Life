extends Node2D
class_name WeaponSlotComponent

@onready var weapon: Entity = get_child(0)
@onready var parent_entity: Entity = get_parent().get_parent()
