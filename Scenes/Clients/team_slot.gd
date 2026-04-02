extends Control
class_name TeamSlot

signal team_slot_slected

@onready var currenty_slected_entity_scene: PackedScene
@onready var currently_selected_entity: Entity

func on_clicked():
	 # Open the selection of playable characters
	team_slot_slected.emit(self)
