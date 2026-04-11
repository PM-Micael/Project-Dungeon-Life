extends Node2D
class_name Inventory

@onready var unit_selection_frame_entity_containers_node: Node2D = get_node("UnitSelectionFrame/EntityContainers")
@onready var unit_preview_frame: Node2D = get_node("UnitLoadoutFrame/UnitPreview")
@onready var weapon_preview_frame: Node2D = get_node("UnitLoadoutFrame/WeaponPreviewFrame")
@onready var backpack_frame: Node2D = get_node("BackpackFrame")

func _ready() -> void:
	_fill_entity_selection_frame()
	_fill_backpack_frame()

func _fill_entity_selection_frame():
	var loop_itterations: int = 0
	for e in DungeonData.dungeon_team:
		var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
		entity_container_instance.entity = e
		entity_container_instance.position = Vector2(100*(loop_itterations+1), -400)
		
		# Makes it clickable
		var clickable_object_scene: PackedScene = load("res://Scenes/Clients/UIComponents/clickable_object.tscn")
		var clickable_object_instance = clickable_object_scene.instantiate()
		clickable_object_instance.scale = Vector2(0.15, 0.15)
		
		entity_container_instance.add_child(clickable_object_instance)
		unit_selection_frame_entity_containers_node.add_child(entity_container_instance)
		loop_itterations += 1

func _fill_backpack_frame():
	var loop_itterations: int = 0
	for e in DungeonData.backpack_contents_as_entities:
		var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
		var clickable_object_scene: PackedScene = load("res://Scenes/Clients/UIComponents/clickable_object.tscn")
		var clickable_object_instance: ClickableObject = clickable_object_scene.instantiate()
		
		entity_container_instance.add_child(clickable_object_instance)
		
		entity_container_instance.entity = e
		entity_container_instance.position = Vector2(75+(loop_itterations*100), 125)
		entity_container_instance.get_node("Sprite2D").scale = Vector2(0.1, 0.1)
		entity_container_instance.get_node("ClickableObject").get_node("CollisionShape2D").scale = Vector2(0.1, 0.1)
		entity_container_instance.get_node("ClickableObject").get_node("PopupMenu").menu_type = PopupMenuType.Type.BACKPACK_ITEM
		
		backpack_frame.add_child(entity_container_instance)
		loop_itterations += 1

# On click events
func entity_container_clicked(entity_container: EntityContainer):
	unit_preview_frame.get_node("Sprite2D").texture = entity_container.entity.get_node("Sprite2D").texture

func on_right_click_option_selected(id: int, entity_container: EntityContainer) -> void:
	match id:
		0:
			print("Not Implimented")
		1:
			print("Attempting to equip item.")
			weapon_preview_frame.get_node("Sprite2D").texture = entity_container.entity.get_node("Sprite2D").texture
		2:
			print("Not Implimented")
