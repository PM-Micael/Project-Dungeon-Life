extends PopupMenu

@onready var menu_type: int

func _ready() -> void:
	if menu_type == null:
		add_item("Null")
	
	match menu_type:
		PopupMenuType.Type.BACKPACK_ITEM:
			add_item("Select", 0)
			add_separator()
			add_item("Equip", 1)
			add_separator()
			add_item("Discard", 2)
			id_pressed.connect(_on_backpack_item_pressed)

func _on_backpack_item_pressed(id: int) -> void:
	get_parent().on_right_click_option_selected(id)
