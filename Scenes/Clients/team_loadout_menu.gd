extends Node2D
class_name TeamLoadoutMenu

var entity_menu_select: PackedScene = preload("res://Scenes/Clients/UIComponents/entity_select_component.tscn")
var available_character_scenes: Array[PackedScene] = [
	preload("res://Scenes/Characters/goblin.tscn"),
	preload("res://Scenes/Characters/golem.tscn"),
	preload("res://Scenes/Characters/petamer.tscn"),
	preload("res://Scenes/Characters/soulbound.tscn"),
	preload("res://Scenes/Characters/orbath.tscn"),
]
var available_characters: Array[Entity]
var character_preview_instance: EntitySelectComponent
var team_comp: Array[Entity]

@onready var currently_selected_team_slot: TeamSlot
@onready var team_slot_amount: int = 4

func _ready() -> void:
	var loop_itteration: int = 0
	for i in range(team_slot_amount):
		var team_slot: PackedScene = load("res://Scenes/Clients/UIComponents/team_slot_1.tscn")
		var instance: TeamSlot = team_slot.instantiate()
		instance.name = "TeamSlot_" + str(loop_itteration+1)
		instance.position = Vector2(400 + (100*loop_itteration), 200)
		instance.team_slot_slected.connect(_on_select_team_slot)
		get_node("TeamSlotsContainer").add_child(instance)
		
		loop_itteration += 1
	
	_fill_available_characters()

func _fill_available_characters():
	for scene in available_character_scenes:
		var instance: Entity = scene.instantiate()
		available_characters.append(instance)

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
	for character in available_characters:
		character_preview_instance = entity_menu_select.instantiate()
		
		character_preview_instance.entity = character
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
	available_characters.erase(new_entity)
	if currently_selected_team_slot.currently_selected_entity != null:
		available_characters.append(currently_selected_team_slot.currently_selected_entity)
	currently_selected_team_slot.currently_selected_entity = new_entity
	currently_selected_team_slot.get_node("Sprite2D").texture = new_entity.get_node("Sprite2D").texture
	_load_character_selection_menu()
