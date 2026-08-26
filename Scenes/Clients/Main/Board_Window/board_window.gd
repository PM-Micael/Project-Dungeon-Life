# Handle user interaction
extends Window
class_name BoardWindow

@onready var board: GameBoard = get_node("Board")

var default_size: Vector2 = Vector2(800, 800)

# Key = board scale, Value = Window position
var layout_config: Dictionary[String, Vector2] = {
	"1.0": Vector2(1120, 240),
	"0.9": Vector2(1200, 320),
	"0.8": Vector2(1280, 400),
	"0.7": Vector2(1360, 480),
	"0.6": Vector2(1440, 560),
	"0.5": Vector2(1520, 640),
	"0.4": Vector2(1600, 720),
	"0.3": Vector2(1680, 800),
	"0.2": Vector2(1760, 880),
	"0.1": Vector2(1840, 960),
}

func _ready() -> void:
	title = "Board"
	position = Vector2(1120, 240)
	unresizable = true
	borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	board.scale_changed.connect(_on_board_scale_changed)
	PlayerData.dungeon_run_ongoing_changed.connect(_on_dungeon_run_selected)

func _on_board_scale_changed(board_scale: Vector2):
	size = default_size * board_scale
	var key: String = "%.1f" % snappedf(board_scale.x, 0.1)
	position = layout_config[key]

func _on_dungeon_run_selected(state: bool, _dungeon: String):
	var unavailable_screen: Node2D = board.get_node("Unavailable")
	unavailable_screen.get_node("TitleLabel").text = "Bord Unavailable"
	unavailable_screen.get_node("DescriptionLabel").text = "You need to choose a dungeon."
	unavailable_screen.visible = not state
