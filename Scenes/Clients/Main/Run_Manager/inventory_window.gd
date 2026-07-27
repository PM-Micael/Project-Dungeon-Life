extends Window
class_name InventoryWindow

var board_scale_x: float
var inventory_scale_x: float

@onready var inventory: Inventory = get_node("UI/Inventory")
@onready var board: GameBoard = get_node("../BoardWindow/Board")

var default_size: Vector2 = Vector2(800, 800)

var layout_config: Dictionary[String, int] = {
	"1.0": 240,
	"0.9": 320,
	"0.8": 400,
	"0.7": 480,
	"0.6": 560,
	"0.5": 640,
	"0.4": 720,
	"0.3": 800,
	"0.2": 880,
	"0.1": 960,
}

func _ready() -> void:
	title = "Inventory"
	position = Vector2(320, 240)
	unresizable = true
	borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	board_scale_x = board.scale.x
	inventory_scale_x = inventory.scale.x
	
	inventory.scale_changed.connect(_on_inventory_scale_changed)
	board.scale_changed.connect(_on_board_scale_changed)

func _on_inventory_scale_changed(inventory_scale: Vector2):
	if inventory_scale.x < inventory_scale_x:
		position.x += 80
	elif inventory_scale.x > inventory_scale_x:
		position.x -= 80
	inventory_scale_x = inventory_scale.x
	
	size = default_size * inventory_scale
	var key: String = "%.1f" % snappedf(inventory_scale.x, 0.1)
	position.y = layout_config[key]

func _on_board_scale_changed(board_scale: Vector2):
	if board_scale.x < board_scale_x:
		position.x += 80
	elif board_scale.x > board_scale_x:
		position.x -= 80
	board_scale_x = board_scale.x
