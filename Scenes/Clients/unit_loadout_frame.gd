extends Node2D
class_name UnitLoadoutFrame

@onready var unit_entity: Entity:
	set(value):
		unit_entity = value
		_on_unit_entity_change()
 
func _on_unit_entity_change():
		get_node("UnitPreview").get_node("Sprite2D").texture = unit_entity.get_node("Sprite2D").texture
		
		var weapon_slot_component = unit_entity.get_node("Components/WeaponSlotComponent")
		var weapon = weapon_slot_component.get_child(0)
		if weapon == null:
			print(unit_entity.display_name + " has no weapon")
			get_node("WeaponPreviewFrame").get_node("Sprite2D").texture = null
			return
		
		get_node("WeaponPreviewFrame").get_node("Sprite2D").texture = weapon.get_node("Sprite2D").texture

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
