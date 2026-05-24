extends Window
class_name InventoryWindow

@onready var inventory: Inventory = get_node("UI/Inventory")

var default_size: Vector2 = Vector2(800, 800)

var layout_config: Dictionary[String, Vector2] = {
	"1.0": Vector2(310, 240),
	"0.9": Vector2(390, 320),
	"0.8": Vector2(470, 400),
	"0.7": Vector2(550, 480),
	"0.6": Vector2(630, 560),
	"0.5": Vector2(710, 640),
	"0.4": Vector2(790, 720),
	"0.3": Vector2(870, 800),
	"0.2": Vector2(950, 880),
	"0.1": Vector2(1030, 960),
}

func _ready() -> void:
	title = "Window Manager"
	position = Vector2(310, 240)
	unresizable = true
	#borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	inventory.scale_changed.connect(_on_inventory_scale_changed)

func _on_inventory_scale_changed(inventory_scale: Vector2):
	size = default_size * inventory_scale
	var key: String = "%.1f" % snappedf(inventory_scale.x, 0.1)
	position = layout_config[key]

func _on_board_scale_changed(board_scale: Vector2):
	var key: String = "%.1f" % snappedf(board_scale.x, 0.1)
	position.x = layout_config[key].x
