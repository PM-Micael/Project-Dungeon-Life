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

var center_menu_showing: bool:
	set(value):
		center_menu_showing = value
		inventory_scale_locked = center_menu_showing
		board_scale_locked = center_menu_showing

var menu_history: Array[TextureButton] = []
var _navigating_back: bool = false
@onready var back_button: TextureButton = get_node("BackButton")

@onready var next_page_button: TextureButton = get_node("NextPageButton")

@onready var home_menu_button: TextureButton = get_node("HomeMenuButton")

@onready var dungeon_menu_button: TextureButton = get_node("DungeonMenuButton")

@onready var board_window: BoardWindow = get_parent().get_node("RunManager/BoardWindow")
@onready var board_menu_button: TextureButton = get_node("Board/BoardMenuButton")
@onready var board_scale_up_button: TextureButton = get_node("Board/BoardScaleUpButton")
@onready var board_scale_down_button: TextureButton = get_node("Board/BoardScaleDownButton")
@onready var board_minimize_button: TextureButton = get_node("Board/BoardMinimizeButton")
var board_scale_locked: bool:
	set(value):
		if value:
			while board_window.board.scale > Vector2(0.4, 0.4):
				_scale_down_board()
		board_scale_locked = value

@onready var inventory_window: InventoryWindow = get_parent().get_node("RunManager/InventoryWindow")
@onready var invenetory_menu_button: TextureButton = get_node("Inventory/InventoryMenuButton")
@onready var inventory_scale_up_button: TextureButton = get_node("Inventory/InventoryScaleUpButton")
@onready var inventory_scale_down_button: TextureButton = get_node("Inventory/InventoryScaleDownButton")
@onready var inventory_minimize_button: TextureButton = get_node("Inventory/InventoryMinimizeButton")
var inventory_scale_locked: bool:
	set(value):
		if value:
			while inventory_window.inventory.scale > Vector2(0.4, 0.4):
				_scale_down_inventory()
		inventory_scale_locked = value

@onready var inner_sanctum_window: InnerSanctumWindow = get_parent().get_node("InnerSanctumWindow")
@onready var inner_sanctum_menu_button: TextureButton = get_node("InnerSanctum/InnerSanctumMenuButton")

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
	
	_connect_events()
		
	config = {
		home_menu_button: [board_menu_button, invenetory_menu_button, dungeon_menu_button, inner_sanctum_menu_button],
		board_menu_button: [board_scale_up_button, board_scale_down_button, board_minimize_button],
		invenetory_menu_button: [inventory_scale_up_button,inventory_scale_down_button, inventory_minimize_button],
		dungeon_menu_button: [],
	}
	
	menu_selected = home_menu_button

func _connect_events():
	back_button.pressed.connect(_on_back_pressed)
	next_page_button.pressed.connect(_on_back_pressed)
	board_menu_button.pressed.connect(_on_board_pressed)
	board_scale_up_button.pressed.connect(_scale_up_board)
	board_scale_down_button.pressed.connect(_scale_down_board)
	board_minimize_button.pressed.connect(_minimize_board)
	invenetory_menu_button.pressed.connect(_on_inventory_pressed)
	inventory_scale_up_button.pressed.connect(_scale_up_inventory)
	inventory_scale_down_button.pressed.connect(_scale_down_inventory)
	inventory_minimize_button.pressed.connect(_minimize_inventory)
	inner_sanctum_menu_button.pressed.connect(_on_inner_sanctum_pressed)
	
	inner_sanctum_window.visibility_changed.connect(func(): _on_window_visibility_changed(inner_sanctum_window))

func _on_window_visibility_changed(window: Window):
	center_menu_showing = window.visible

func _on_menu_selected_changed() -> void: #Potential for adding a check to minimize unececary loop itterations.
	if config.is_empty():
		return
	
	# Potential check
	
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
				child.position = Vector2(265, 25)
			1:
				child.position = Vector2(265, 105)
			2:
				child.position = Vector2(185, 130)
			3:
				child.position = Vector2(105, 130)
		
		loop_itteration += 1

# Back button
func _on_back_pressed():
	if menu_history.is_empty():
		return
	_navigating_back = true
	menu_selected = menu_history.pop_back()
	_navigating_back = false

# Board menu button
func _on_board_pressed():
	if menu_selected != board_menu_button:
		menu_selected = board_menu_button

func _scale_down_board():
	if not board_scale_locked:
		if not board_window.visible:
			board_window.visible = true
			return
		var board_scale: Vector2 = board_window.board.scale
		board_window.board.set_scale_custom = board_scale - Vector2(0.1, 0.1)

func _scale_up_board():
	if not board_scale_locked:
		if not board_window.visible:
			board_window.visible = true
			return
		
		board_window.visible = true
		var board_scale: Vector2 = board_window.board.scale
		board_window.board.set_scale_custom = board_scale + Vector2(0.1, 0.1)

func _minimize_board():
	board_window.visible = not board_window.visible

# Inventory menu button
func _on_inventory_pressed():
	if menu_selected != invenetory_menu_button:
		menu_selected = invenetory_menu_button

func _scale_up_inventory():
	if not inventory_scale_locked:
		if not inventory_window.visible:
			inventory_window.visible = true
			return
		
		var inventory_scale: Vector2 = inventory_window.inventory.scale
		inventory_window.inventory.set_scale_custom = inventory_scale + Vector2(0.1, 0.1)

func _scale_down_inventory():
	if not inventory_scale_locked:
		if not inventory_window.visible:
			inventory_window.visible = true
			return
		
		var inventory_scale: Vector2 = inventory_window.inventory.scale
		inventory_window.inventory.set_scale_custom = inventory_scale - Vector2(0.1, 0.1)

func _minimize_inventory():
	inventory_window.visible = not inventory_window.visible

# Inner Sanctum
func _on_inner_sanctum_pressed():
	inner_sanctum_window.visible = not inner_sanctum_window.visible
