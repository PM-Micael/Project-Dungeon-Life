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
	unit_container_instance.position = Vector2(425, -225.0)
	unit_container_instance.scale = Vector2(2, 2)
	get_node("UnitPreview").add_child(unit_container_instance)
	
	var weapon_container_instance: EntityContainer = container_scene.instantiate()
	weapon_container_instance.name = "WeaponContainer"
	weapon_container_instance.position = Vector2(150, -175)
	weapon_container_instance.scale = Vector2(1.5, 1.5)
	get_node("WeaponPreviewFrame").add_child(weapon_container_instance)
	
	unit_entity_container = get_node("UnitPreview/UnitContainer")
	weapon_entity_container = get_node("WeaponPreviewFrame/WeaponContainer")
	
func _on_unit_entity_change():
	unit_entity_container.entity = unit_entity
	
	var weapon_slot_component = unit_entity.get_node("Components/WeaponSlotComponent")
	if weapon_slot_component != null:
		var weapon = weapon_slot_component.get_child(0)
		if weapon == null:
			weapon_entity_container.entity = null
		else:
			weapon_entity_container.entity = weapon

	# Update StatsFrame
	get_node("StatsFrame/Health/ValueLabel").text = str(unit_entity.health_component.current_health) + "/" + str(unit_entity.health_component.max_health)
	get_node("StatsFrame/Attack/ValueLabel").text = str(unit_entity.attack_component.attack_damage)

	# Connect signals for real-time updates (disconnect first to avoid duplicates)
	if unit_entity.health_component.damage_taken.is_connected(_on_selected_unit_health_changed):
		unit_entity.health_component.damage_taken.disconnect(_on_selected_unit_health_changed)
	unit_entity.health_component.damage_taken.connect(_on_selected_unit_health_changed)

	if unit_entity.attack_component.post_attack_target.is_connected(_on_selected_unit_attacked):
		unit_entity.attack_component.post_attack_target.disconnect(_on_selected_unit_attacked)
	unit_entity.attack_component.post_attack_target.connect(_on_selected_unit_attacked)

func _on_selected_unit_health_changed(_attacker: Entity):
	if not is_instance_valid(unit_entity):
		return
	get_node("StatsFrame/Health/ValueLabel").text = str(unit_entity.health_component.current_health) + "/" + str(unit_entity.health_component.max_health)

func _on_selected_unit_attacked(_targets: Array[Entity]):
	if not is_instance_valid(unit_entity):
		return
	get_node("StatsFrame/Attack/ValueLabel").text = str(unit_entity.attack_component.attack_damage)

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
