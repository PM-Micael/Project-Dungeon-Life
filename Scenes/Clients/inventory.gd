extends Node2D
class_name Inventory

@onready var unit_selection_frame_entity_containers_node: Node2D = get_node("UnitSelectionFrame/EntityContainers")
@onready var unit_preview_frame: Node2D = get_node("UnitLoadoutFrame/UnitPreview")

func _ready() -> void:
	var loop_itteration: int = 0
	for e in Globals.dungeon_team:
		var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
		entity_container_instance.entity = e
		entity_container_instance.position = Vector2(100*(loop_itteration+1), -400)
		
		var clickable_object_scene: PackedScene = load("res://Scenes/Clients/UIComponents/clickable_object.tscn")
		var clickable_object_instance = clickable_object_scene.instantiate()
		clickable_object_instance.scale = Vector2(0.15, 0.15)
		
		entity_container_instance.add_child(clickable_object_instance)
		unit_selection_frame_entity_containers_node.add_child(entity_container_instance)
		loop_itteration += 1

func entity_container_clicked(entity_container: EntityContainer):
	unit_preview_frame.get_node("Sprite2D").texture = entity_container.entity.get_node("Sprite2D").texture
