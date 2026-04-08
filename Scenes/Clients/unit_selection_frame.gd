extends Node2D

@onready var intentory_parent: Inventory = get_parent()

func entity_container_clicked(entity_conteinr: EntityContainer):
	intentory_parent.entity_container_clicked(entity_conteinr)
