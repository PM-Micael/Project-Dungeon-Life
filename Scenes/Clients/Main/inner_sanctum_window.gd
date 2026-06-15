# Handle user interaction
extends Window
class_name InnerSanctumWindow

@onready var inner_sanctum: InnerSanctum = get_node("InnerSanctum")

var default_size: Vector2 = Vector2(640, 219)

func _ready() -> void:
	title = "Window Manager"
	position = Vector2(640, 219)
	unresizable = true
	borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	PlayerData.dungeon_run_ongoing_changed.connect(_on_dungeon_run_ongoing_changed)

func _on_dungeon_run_ongoing_changed(state: bool, _dungeon: String):
	var unavailable_screen: Node2D = inner_sanctum.get_node("UnavailableScreen")
	unavailable_screen.get_node("TitleLabel").text = "Dungeon Selection is unavailale"
	unavailable_screen.get_node("DescriptionLabel").text = "Cannot upgrade Inner Sanctum. Dungeon run is in progress."
	unavailable_screen.visible = state
