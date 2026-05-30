extends Node2D
class_name Inventory

signal scale_changed()

var set_scale_custom: Vector2:
	set(value):
		if value > Vector2(1.0, 1.0) or value < Vector2(0.1, 0.1):
			return
		if scale != value:
			scale = value
			scale_changed.emit(scale)


@onready var run_manager: RunManager = get_parent().get_parent().get_parent()
@onready var unit_loadout_frame: UnitLoadoutFrame = get_node("UnitLoadoutFrame")
@onready var unit_preview_frame: Node2D = get_node("UnitLoadoutFrame/UnitPreview")
@onready var weapon_preview_frame: Node2D = get_node("UnitLoadoutFrame/WeaponPreviewFrame")
@onready var backpack_frame: Node2D = get_node("BackpackFrame")

func _ready() -> void:
	fill_backpack_frame()

func fill_backpack_frame():
	for child in backpack_frame.get_node("Items").get_children():
		child.queue_free()
		
	var loop_count: int = 0
	for e in DungeonData.backpack_contents_as_entities:
		var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
		var clickable_object_scene: PackedScene = load("res://Scenes/Clients/UIComponents/clickable_object.tscn")
		var clickable_object_instance: Control = clickable_object_scene.instantiate()
		
		entity_container_instance.add_child(clickable_object_instance)
		
		entity_container_instance.entity = e
		entity_container_instance.position = Vector2(25+(loop_count*100), 50)
		entity_container_instance.get_node("ClickableObject").get_node("Clickable").scale = Vector2(0.1, 0.1)
		entity_container_instance.get_node("ClickableObject").get_node("Clickable").get_node("PopupMenu").menu_type = PopupMenuType.Type.BACKPACK_ITEM
		
		backpack_frame.get_node("Items").add_child(entity_container_instance)
		loop_count += 1

# On click events
func entity_unit_selection_container_clicked(entity_container: EntityContainer):
	unit_loadout_frame.unit_entity = entity_container.entity

func on_right_click_option_selected(id: int, entity_container: EntityContainer) -> void:
	match id:
		0:
			print("Not Implimented")
		1:
			print("Attempting to equip item")
			if unit_loadout_frame.unit_entity == null:
				print("No unit selected")
				return
			
			entity_container.remove_child(entity_container.entity)
			
			var old_weapon: Entity = DungeonData.set_unit_entity_weapon(unit_loadout_frame.unit_entity, entity_container.entity)
			DungeonData.backpack_contents_as_entities.erase(entity_container.entity)
			
			if old_weapon != null:
				DungeonData.backpack_contents_as_entities.append(old_weapon)
				
			DungeonData.check_and_merge_backpack_items()
			
			unit_loadout_frame._on_unit_entity_change()
			fill_backpack_frame()
		2:
			print("Not Implimented")
