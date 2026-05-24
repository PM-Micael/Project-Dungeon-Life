# Handle user interaction
extends Window
class_name BoardWindow

@onready var board: GameBoard = get_node("Board")

var default_size: Vector2 = Vector2(800, 800)

func _ready() -> void:
	title = "Window Manager"
	position = Vector2(1119, 240)
	unresizable = true
	#borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	board.scale_changed.connect(_on_board_scale_changed)

func _on_board_scale_changed(board_scale: Vector2):
	size = default_size * board_scale
