# Handle user interaction
extends Window
class_name DungeonSelectionWindow

const default_size: Vector2 = Vector2(640, 219)

@onready var dungeon_selection: DungeonSelection = get_node("DungeonSelection")

func _ready() -> void:
	title = "Dungeon Selection Window"
	position = Vector2(490, 219)
	unresizable = true
	borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	PlayerData.dungeon_run_ongoing_changed.connect(_on_dungeon_run_ongoing_changed)

func _on_dungeon_run_ongoing_changed(state: bool, _dungeon: String):
	var unavailable_screen: Node2D = dungeon_selection.get_node("UnavailableScreen")
	unavailable_screen.get_node("TitleLabel").text = "Dungeon Selection is unavailale."
	unavailable_screen.get_node("DescriptionLabel").text = "Cannot select dungeon. Dungeon run is already in progress."
	unavailable_screen.visible = state
	dungeon_selection.initialize_data()
	
