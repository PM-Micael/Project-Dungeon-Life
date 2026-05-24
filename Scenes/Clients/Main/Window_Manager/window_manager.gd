extends Window
class_name WindowManager

var menu_selected_position: Vector2
var menu_selected_scale: Vector2
var menu_is_selected: bool = false
var menu_selected: TextureButton:
	set(value):
		if menu_selected != null and not _navigating_back:
			menu_history.append(menu_selected)
		menu_selected = value
		_on_menu_selected_changed()

var menu_history: Array[TextureButton] = []
var _navigating_back: bool = false
var back_button: TextureButton

var next_page_button: TextureButton

var home_menu_button: TextureButton

var dungeon_menu_button: TextureButton

var board_menu_button: TextureButton
var board_scale_up_button: TextureButton
var board_scale_down_button: TextureButton
var board_minimize_button: TextureButton

var invenetory_menu_button: TextureButton
var inventory_scale_down_button: TextureButton
var inventory_scale_up_button: TextureButton
var inventory_minimize_button: TextureButton

var config: Dictionary[TextureButton, Array]

func _ready() -> void:
	title = "Window Manager"
	size = Vector2i(350, 200)
	position = Vector2i(700, 0)
	unresizable = true
	borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	# Back button
	_add_back_button()
	
	# Next page button
	_add_next_page_button()
	
	# Main menu
	_add_main_menu_button()
	
	# Dungeon menu
	_add_home_menu_button()
	
	# Board
	_add_board_menu_button()
	_add_board_scale_up_button()
	_add_board_scale_down_button()
	_add_board_minimize_button()
	
	_add_inventory_menu_button()
	_add_inventory_scale_up_button()
	_add_inventory_scale_down_button()
	_add_inventory_minimize_button()
	
	config = {
		home_menu_button: [board_menu_button, invenetory_menu_button, dungeon_menu_button],
		board_menu_button: [board_scale_up_button, board_scale_down_button, board_minimize_button],
		invenetory_menu_button: [inventory_scale_up_button,inventory_scale_down_button, inventory_minimize_button],
		dungeon_menu_button: []
	}
	
	menu_selected = home_menu_button

func _on_menu_selected_changed() -> void:
	if config.is_empty():
		return
	
	for button in config.keys():
		button.visible = false
		button.scale = Vector2(0.75, 0.75)
		for child in config[button]:
			if child != null:
				child.visible = false
	
	if menu_selected == home_menu_button:
		back_button.visible = false
	else:
		back_button.visible = true

	# Show and position selected button large in the center
	menu_selected.visible = true
	menu_selected.scale = Vector2(1, 1)
	menu_selected.position = Vector2(130, 0)

	# Show its children from config
	var children: Array = config.get(menu_selected, [])
	var loop_itteration: int = 0
	for i in children.size():
		var child: Node = children[i]
		if child == null:
			continue
		child.visible = true
		match loop_itteration:
			0:
				child.position = Vector2(280, 25)
			1:
				child.position = Vector2(270, 100)
			2:
				child.position = Vector2(195, 130)
			3:
				child.position = Vector2(195, 130)
		
		loop_itteration += 1

# Back button
func _add_back_button():
	back_button = TextureButton.new()
	back_button.name = "back_button"
	back_button.texture_normal = load("res://Assets/Client/icon_go_back.svg")
	back_button.scale = Vector2(0.5, 0.5)
	back_button.position = Vector2(80, 0)
	back_button.pressed.connect(_on_back_pressed)
	back_button.visible = true
	add_child(back_button)

func _on_back_pressed():
	if menu_history.is_empty():
		return
	_navigating_back = true
	menu_selected = menu_history.pop_back()
	_navigating_back = false

# Next page button
func _add_next_page_button():
	next_page_button = TextureButton.new()
	next_page_button.name = "next_page_button"
	next_page_button.texture_normal = load("res://Assets/Client/icon_go_forward.svg")
	next_page_button.scale = Vector2(0.5, 0.5)
	next_page_button.position = Vector2(225, 0)
	next_page_button.pressed.connect(_on_back_pressed)
	next_page_button.visible = false
	add_child(next_page_button)

# Main menu button
func _add_main_menu_button():
	home_menu_button = TextureButton.new()
	home_menu_button.name = "home_menu_button"
	home_menu_button.texture_normal = load("res://Assets/Client/icon_main_menu.svg")
	add_child(home_menu_button)

# Dungeon menu
func _add_home_menu_button():
	dungeon_menu_button = TextureButton.new()
	dungeon_menu_button.name = "dungeon_menu_button"
	dungeon_menu_button.texture_normal = load("res://Assets/Client/icon_dungeon.svg")
	dungeon_menu_button.scale = Vector2(0.75, 0.75)
	dungeon_menu_button.visible = false
	add_child(dungeon_menu_button)

# Board menu button
func _add_board_menu_button():
	board_menu_button = TextureButton.new()
	board_menu_button.name = "baord_menu_button"
	board_menu_button.texture_normal = load("res://Assets/Client/icon_board.svg")
	board_menu_button.scale = Vector2(0.75, 0.75)
	board_menu_button.pressed.connect(_on_board_pressed)
	board_menu_button.visible = false
	add_child(board_menu_button)

func _on_board_pressed():
	if menu_selected != board_menu_button:
		menu_selected = board_menu_button

func _add_board_scale_up_button():
	board_scale_up_button = TextureButton.new()
	board_scale_up_button.name = "board_scale_up_button"
	board_scale_up_button.texture_normal = load("res://Assets/Client/icon_scale_up.svg")
	board_scale_up_button.scale = Vector2(0.75, 0.75)
	board_scale_up_button.visible = false
	add_child(board_scale_up_button)

func _add_board_scale_down_button():
	board_scale_down_button = TextureButton.new()
	board_scale_down_button.name = "board_scale_down_button"
	board_scale_down_button.texture_normal = load("res://Assets/Client/icon_scale_down.svg")
	board_scale_down_button.scale = Vector2(0.75, 0.75)
	board_scale_down_button.pressed.connect(_on_board_pressed)
	board_scale_down_button.visible = false
	add_child(board_scale_down_button)

func _add_board_minimize_button():
	board_minimize_button = TextureButton.new()
	board_minimize_button.name = "board_minimize_down_button"
	board_minimize_button.texture_normal = load("res://Assets/Client/icon_minimize.svg")
	board_minimize_button.scale = Vector2(0.75, 0.75)
	board_minimize_button.pressed.connect(_on_board_pressed)
	board_minimize_button.visible = false
	add_child(board_minimize_button)

# Inventory menu button
func _add_inventory_menu_button():
	invenetory_menu_button = TextureButton.new()
	invenetory_menu_button.name = "inventory_menu_button"
	invenetory_menu_button.texture_normal = load("res://Assets/Client/icon_inventory.svg")
	invenetory_menu_button.scale = Vector2(0.75, 0.75)
	invenetory_menu_button.pressed.connect(_on_inventory_pressed)
	invenetory_menu_button.visible = false
	add_child(invenetory_menu_button)

func _on_inventory_pressed():
	if menu_selected != invenetory_menu_button:
		menu_selected = invenetory_menu_button

func _add_inventory_scale_up_button():
	inventory_scale_up_button = TextureButton.new()
	inventory_scale_up_button.name = "inventory_scale_up_button"
	inventory_scale_up_button.texture_normal = load("res://Assets/Client/icon_scale_up.svg")
	inventory_scale_up_button.scale = Vector2(0.75, 0.75)
	inventory_scale_up_button.visible = false
	add_child(inventory_scale_up_button)

func _add_inventory_scale_down_button():
	inventory_scale_down_button = TextureButton.new()
	inventory_scale_down_button.name = "inventory_scale_down_button"
	inventory_scale_down_button.texture_normal = load("res://Assets/Client/icon_scale_down.svg")
	inventory_scale_down_button.scale = Vector2(0.75, 0.75)
	inventory_scale_down_button.visible = false
	add_child(inventory_scale_down_button)

func _add_inventory_minimize_button():
	inventory_minimize_button = TextureButton.new()
	inventory_minimize_button.name = "inventory_minimize_down_button"
	inventory_minimize_button.texture_normal = load("res://Assets/Client/icon_minimize.svg")
	inventory_minimize_button.scale = Vector2(0.75, 0.75)
	inventory_minimize_button.pressed.connect(_on_board_pressed)
	inventory_minimize_button.visible = false
	add_child(inventory_minimize_button)
