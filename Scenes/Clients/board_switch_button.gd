extends Button

@onready var team_lineup_menu: TeamLineupMenu = get_parent().get_parent()

func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():	
	if name == "Button":
		if team_lineup_menu.current_board_layout_id == 1:
			team_lineup_menu.current_board_layout_id = 2
		elif team_lineup_menu.current_board_layout_id == 2:
			team_lineup_menu.current_board_layout_id = 1 
	elif name == "Button2":
		if team_lineup_menu.current_inventory_layout_id == 1:
			team_lineup_menu.current_inventory_layout_id = 2
		elif team_lineup_menu.current_inventory_layout_id == 2:
			team_lineup_menu.current_inventory_layout_id = 1 
