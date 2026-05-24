extends Control
class_name ClickableObject

@onready var parent = get_parent().get_parent()
@onready var popup_menu: PopupMenu = get_node("PopupMenu")

func _ready() -> void:
	return

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				parent.on_clicked()
			MOUSE_BUTTON_RIGHT:
				if popup_menu == null:
					return
				popup_menu.position = get_viewport().get_mouse_position()
				popup_menu.popup()

func _create_popup_menu():
	popup_menu = PopupMenu.new()
	add_child(popup_menu)

func on_right_click_option_selected(id: int):
	print("Clicked id: " + str(id))
	parent.on_right_click_option_selected(id)
