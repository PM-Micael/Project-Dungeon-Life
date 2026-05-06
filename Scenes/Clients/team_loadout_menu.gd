extends Node2D
class_name TeamLoadoutMenu

var entity_menu_select: PackedScene = preload("res://Scenes/Clients/UIComponents/entity_select_component.tscn")
var character_preview_instance: EntitySelectComponent # Can be replaced with clickalee_object ???

@onready var currently_selected_team_slot: TeamSlot
@onready var team_slots: Array[TeamSlot]
@onready var team_slot_amount: int = 4

func _ready() -> void:
	DungeonData.initialize_data()
	
	# Adds TeamSlots in the scene
	var loop_itteration: int = 0
	for i in range(team_slot_amount):
		var team_slot: PackedScene = load("res://Scenes/Clients/UIComponents/team_slot_1.tscn")
		var team_slot_instance: TeamSlot = team_slot.instantiate()
		team_slot_instance.name = "TeamSlot_" + str(loop_itteration+1)
		team_slot_instance.position = Vector2(400 + (100*loop_itteration), 200)
		team_slot_instance.team_slot_slected.connect(_on_select_team_slot)
		team_slots.append(team_slot_instance)
		get_node("TeamSlotsContainer").add_child(team_slot_instance)
		
		if loop_itteration == 0:
			currently_selected_team_slot = team_slot_instance
		
		loop_itteration += 1
	
	_load_character_selection_menu()

func _on_select_team_slot(team_slot_scene: TeamSlot):
	currently_selected_team_slot = team_slot_scene
	print("currenty_selected_team_slot = " + str(currently_selected_team_slot.name))
	
	_load_character_selection_menu()

func _load_character_selection_menu():
	var children = get_node("EntitySelectMenu").get_children()
	if children != null and children.size() != 0:
		for child in children:
			child.queue_free()
	
	var loop_itteration = 0
	for unit in DungeonData.available_units_as_entities:
		character_preview_instance = entity_menu_select.instantiate()
		
		character_preview_instance.entity = unit
		character_preview_instance.name += "_" + str(loop_itteration)
		character_preview_instance.get_node("Sprite2D").scale = Vector2(0.2, 0.2)
		character_preview_instance.get_node("ClickableEntity").get_node("CollisionShape2D").scale = Vector2(0.2, 0.2)
		character_preview_instance.get_node("ClickableEntity").get_node("PopupMenu").menu_type = PopupMenuType.Type.NONE
		character_preview_instance.position = Vector2(100 * (loop_itteration+1), 500)
		character_preview_instance.selected.connect(_on_character_chosen)
		
		get_node("EntitySelectMenu").add_child(character_preview_instance)
		loop_itteration += 1

func _on_character_chosen(new_entity: Entity):
	if (new_entity in DungeonData.dungeon_team):
		print("No dupes allowed.")
		return
	
	PlayerData.dungeon_team.append(new_entity)
	PlayerData.dungeon_team.erase(currently_selected_team_slot.currently_selected_entity)
	DungeonData.available_units_as_entities.erase(new_entity)
	if currently_selected_team_slot.currently_selected_entity != null:
		DungeonData.available_units_as_entities.append(currently_selected_team_slot.currently_selected_entity)
	currently_selected_team_slot.currently_selected_entity = new_entity
	currently_selected_team_slot.get_node("Sprite2D").texture = new_entity.get_node("Sprite2D").texture
	
	for s in team_slots:
		if s.currently_selected_entity == null:
			currently_selected_team_slot = s
			break
	
	_load_character_selection_menu()
