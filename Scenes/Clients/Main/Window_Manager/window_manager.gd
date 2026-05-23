extends Window
class_name WindowManager

var menu_selected_position: Vector2
var menu_selected_scale: Vector2
var menu_is_selected: bool = false
var menu_selected: TextureButton:
	set(value):
		menu_selected = value
		_on_menu_selected_changed()

var main_menu_button: TextureButton

var board_menu_button: TextureButton
var board_scale_down_button: TextureButton
var board_scale_up_button: TextureButton

var invenetory_menu_button: TextureButton
var inventory_scale_down_button: TextureButton
var inventory_scale_up_button: TextureButton

var config: Dictionary

func _ready() -> void:
	title = "Window Manager"
	size = Vector2i(300, 300)
	position = Vector2i(800, 0)
	unresizable = true
	borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	_add_main_menu_button()
	_add_board_menu_button()
	_add_inventory_menu_button()
	
	config = {
		main_menu_button: [board_menu_button, invenetory_menu_button],
		board_menu_button: [board_scale_down_button],
		invenetory_menu_button: [inventory_scale_down_button]
	}
	
	menu_selected = main_menu_button

func _on_menu_selected_changed() -> void:
	if config.is_empty():
		return

	# Hide all buttons except the selected one
	for button in config.keys():
		button.visible = (button == menu_selected)
		button.scale = Vector2(0.75, 0.75)

	# Show and position selected button large in the center
	menu_selected.scale = Vector2(1, 1)
	menu_selected.position = Vector2(100, 0)

	# Show its children from config
	var children: Array = config.get(menu_selected, [])
	var loop_itteration: int = 0
	for i in children.size():
		var child: Node = children[i]
		if child == null:
			continue
		child.visible = false
		match loop_itteration:
			0:
				child.position = Vector2(0, 0)
			1:
				child.position = Vector2(0, 100)
		
		loop_itteration += 1

# Main menu button
func _add_main_menu_button():
	main_menu_button = TextureButton.new()
	main_menu_button.name = "main_menu_button"
	main_menu_button.texture_normal = load("res://Assets/Client/icon_main_menu.svg")
	main_menu_button.mouse_entered.connect(_on_main_hover)
	main_menu_button.mouse_exited.connect(_on_main_hover_end)
	main_menu_button.position = Vector2(100, 0)
	add_child(main_menu_button)

func _on_main_hover():
	if menu_selected == main_menu_button:
		await get_tree().create_timer(0.1).timeout
		if main_menu_button.is_hovered():
			var children: Array = config.get(menu_selected, [])
			for child in children:
				if child != null:
					child.visible = true

func _on_main_hover_end():
	return
	await get_tree().create_timer(0.1).timeout
	board_menu_button.visible = false
	invenetory_menu_button.visible = false
	print("Close weel")

# Board menu button
func _add_board_menu_button():
	board_menu_button = TextureButton.new()
	board_menu_button.name = "baord_menu_button"
	board_menu_button.texture_normal = load("res://Assets/Client/icon_board.svg")
	board_menu_button.scale = Vector2(0.75, 0.75)
	board_menu_button.position = Vector2(0, 0)
	board_menu_button.pressed.connect(_on_board_pressed)
	board_menu_button.mouse_entered.connect(_on_board_hover)
	board_menu_button.visible = false
	add_child(board_menu_button)

func _on_board_hover():
	if menu_selected == board_menu_button:
		print("board hover")

func _on_board_pressed():
	menu_selected = board_menu_button

func _add_board_scale_up_button():
	board_scale_up_button = TextureButton.new()
	board_scale_up_button.name = "board_scale_up_button"
	board_scale_up_button.texture_normal = load("res://Assets/Client/icon_board.svg")
	board_scale_up_button.scale = Vector2(0.75, 0.75)
	board_scale_up_button.position = Vector2(0, 0)
	board_scale_up_button.pressed.connect(_on_board_pressed)
	board_scale_up_button.visible = false
	add_child(board_scale_up_button)

# Inventory menu button
func _add_inventory_menu_button():
	invenetory_menu_button = TextureButton.new()
	invenetory_menu_button.name = "inventory_menu_button"
	invenetory_menu_button.texture_normal = load("res://Assets/Client/icon_inventory.svg")
	invenetory_menu_button.scale = Vector2(0.75, 0.75)
	invenetory_menu_button.position = Vector2(0, 100)
	invenetory_menu_button.visible = false
	add_child(invenetory_menu_button)
