extends Node2D

@onready var intentory_parent: Inventory = get_parent()

func entity_container_clicked(entity_conteinr: EntityContainer):
	print("Clicked. Add function for right click and stuff in BackpackFrame")

func on_right_click_option_selected(id: int, entity_container: EntityContainer) -> void:
	print(entity_container.entity.name + " clicked in inventory. [In BackpackFrame]")
	intentory_parent.on_right_click_option_selected(id, entity_container)
