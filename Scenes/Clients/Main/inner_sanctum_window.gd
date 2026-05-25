# Handle user interaction
extends Window
class_name InnerSanctumWindow

@onready var inner_sanctum: InnerSanctum = get_node("InnerSanctum")

var default_size: Vector2 = Vector2(600, 600)

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
	title = "Window Manager"
	position = Vector2(900, 219)
	unresizable = true
	borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	#inner_sanctum.scale_changed.connect(_on_inner_sanctum_scale_changed)

func _on_inner_sanctum_scale_changed(inner_sanctum_scale: Vector2):
	size = default_size * inner_sanctum_scale
	var key: String = "%.1f" % snappedf(inner_sanctum_scale.x, 0.1)
	position = layout_config[key]
