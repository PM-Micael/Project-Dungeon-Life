extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():	
	if name == "Button":
		if LocalData.current_board_layout_id == 1:
			LocalData.current_board_layout_id = 2
		elif LocalData.current_board_layout_id == 2:
			LocalData.current_board_layout_id = 1 
	elif name == "Button2":
		if LocalData.current_inventory_layout_id == 1:
			LocalData.current_inventory_layout_id = 2
		elif LocalData.current_inventory_layout_id == 2:
			LocalData.current_inventory_layout_id = 1 
