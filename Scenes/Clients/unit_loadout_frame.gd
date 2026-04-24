extends Node2D
class_name UnitLoadoutFrame

@onready var unit_entity: Entity:
	set(value):
		unit_entity = value
		_on_unit_entity_change()
 
var unit_entity_container: EntityContainer
var weapon_entity_container: EntityContainer

func _ready() -> void:
	var container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
	var unit_container_instance = container_scene.instantiate()
	unit_container_instance.name = "UnitContainer"
	unit_container_instance.position = Vector2(412.5, -225.0)
	unit_container_instance.scale = Vector2(2, 2)
	get_node("UnitPreview").add_child(unit_container_instance)
	
	var weapon_container_instance: EntityContainer = container_scene.instantiate()
	weapon_container_instance.name = "WeaponContainer"
	weapon_container_instance.position = Vector2(150, -225)
	weapon_container_instance.scale = Vector2(1.5, 1.5)
	get_node("WeaponPreviewFrame").add_child(weapon_container_instance)
	
	
	unit_entity_container = get_node("UnitPreview/UnitContainer")
	weapon_entity_container = get_node("WeaponPreviewFrame/WeaponContainer")
	

func _on_unit_entity_change():
	unit_entity_container.entity = unit_entity
	
	var weapon_slot_component = unit_entity.get_node("Components/WeaponSlotComponent")
	var weapon = weapon_slot_component.get_child(0)
	if weapon == null:
		print(unit_entity.display_name + " has no weapon")
		weapon_entity_container.entity = null
		return
	
	weapon_entity_container.entity = weapon

func change_unit_weapon(new_weapon_entity: Entity):
	print("Changing unit weapon")
	var unit_weapon_slot_component: Entity = unit_entity.get_node("Components/WeaponSlotComponent")
	var unit_weapon = unit_weapon_slot_component.get_child(0)
	if unit_weapon != null:
		unit_weapon.free()
	
	unit_weapon_slot_component.add_child(new_weapon_entity)
	
	# Update the selection
	var unit_selection_container_entities: Array[EntityContainer] = get_parent().unit_selection_frame_entity_containers_node.get_children()
	for u in unit_selection_container_entities:
		if u.entity.display_name == unit_entity.display_name:
			u.entity = unit_entity
