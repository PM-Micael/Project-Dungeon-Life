extends Window
class_name InventoryWindow

@onready var inventory: Inventory = get_node("UI/Inventory")

var default_size: Vector2 = Vector2(800, 800)

func _ready() -> void:
	title = "Window Manager"
	position = Vector2(311, 240)
	unresizable = true
	#borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	inventory.scale_changed.connect(_on_inventory_scale_changed)

func _on_inventory_scale_changed(inventory_scale: Vector2):
	size = default_size * inventory_scale
