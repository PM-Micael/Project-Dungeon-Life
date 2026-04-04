extends Node2D
class_name TeamLoadoutMenu

var entity_menu_select: PackedScene = preload("res://Scenes/Clients/UIComponents/entity_select_component.tscn")
var character_scenes: Array[PackedScene] = [
	preload("res://Scenes/Characters/goblin.tscn"),
	preload("res://Scenes/Characters/golem.tscn"),
	preload("res://Scenes/Characters/petamer.tscn"),
]
var available_characters: Array[Entity]
var character_preview_instance: EntitySelectComponent
var team_comp: Array

@onready var team_slot_1: TeamSlot = get_node_or_null("TeamSlotsContainer/TeamSlot1")
@onready var team_slot_2: TeamSlot = get_node_or_null("TeamSlotsContainer/TeamSlot2")
@onready var team_slot_3: TeamSlot = get_node_or_null("TeamSlotsContainer/TeamSlot3")
@onready var team_slot_4: TeamSlot = get_node_or_null("TeamSlotsContainer/TeamSlot4")
@onready var currently_selected_team_slot: TeamSlot

func _ready() -> void:
	_fill_available_characters()
	_connect_signals()

func _fill_available_characters():
	for scene in character_scenes:
		var instance:Entity = scene.instantiate()
		available_characters.append(instance)

func _connect_signals():
	# When you seleect a team slot
	team_slot_1.team_slot_slected.connect(_on_select_team_slot)
	team_slot_2.team_slot_slected.connect(_on_select_team_slot)
	team_slot_3.team_slot_slected.connect(_on_select_team_slot)
	team_slot_4.team_slot_slected.connect(_on_select_team_slot)

func _on_select_team_slot(team_slot_scene: TeamSlot):
	currently_selected_team_slot = team_slot_scene
	print("currenty_selected_team_slot = " + str(currently_selected_team_slot.name))
	
	_load_character_selection_menu()

func _load_character_selection_menu():
	var children = get_node("EntitySelectMenu").get_children()
	if children != null and children.size() != 0:
		for child in children:
			child.free()
	
	var loop_itteration = 0
	for character in available_characters:
		character_preview_instance = entity_menu_select.instantiate()
		
		character_preview_instance.entity_scene = character
		character_preview_instance.name += "_" + str(loop_itteration)
		character_preview_instance.scale = Vector2(0.2, 0.2)
		character_preview_instance.position = Vector2(100 * (loop_itteration+1), 500)
		character_preview_instance.selected.connect(_on_character_chosen)
		
		get_node("EntitySelectMenu").add_child(character_preview_instance)
		loop_itteration += 1

func _on_character_chosen(new_entity: Entity):
	if (new_entity in team_comp):
		print("No dupes allowed.")
		return
	
	
	team_comp.append(new_entity)
	print(str(new_entity.name) + " was added to team")
	team_comp.erase(currently_selected_team_slot.currently_selected_entity)
	currently_selected_team_slot.currently_selected_entity = new_entity
	currently_selected_team_slot.get_node("Sprite2D").texture = new_entity.get_node("Sprite2D").texture
