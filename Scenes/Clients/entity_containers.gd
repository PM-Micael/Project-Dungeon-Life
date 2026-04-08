extends Node2D

func entity_container_clicked(entity_container: EntityContainer):
	get_parent().entity_container_clicked(entity_container)
