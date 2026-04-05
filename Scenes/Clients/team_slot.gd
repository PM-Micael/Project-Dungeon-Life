extends Control
class_name TeamSlot

signal team_slot_slected

@onready var currently_selected_entity: Entity

func on_clicked():
	 # Open the selection of playable characters
	team_slot_slected.emit(self)
