# Handle user interaction
extends Window
class_name BoardWindow

@onready var board_scene = preload("res://Scenes/Clients/board.tscn")

@onready var currently_selected_unit_entity_container: EntityContainer

var board: GameBoard
var map_tiles: MapTiles
var next_stage_button: Button
var exit_dungeon_button: Button
var start_stage_button: Button

func _ready() -> void:
	title = "Window Manager"
	size = Vector2i(800, 800)
	position = Vector2i(800, 800)
	unresizable = true
	#borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	add_board_scene()
	
	_connect_events()

func add_board_scene():
	var get_inner_sanctum = get_node_or_null("InnerSanctum")
	if get_inner_sanctum != null:
		get_inner_sanctum.queue_free()
		
	var instance = board_scene.instantiate()
	add_child(instance)
	move_child(instance, 0)
	board = get_node("WindowManager/Board")
	map_tiles = get_node_or_null("Board/MapTiles")
	next_stage_button = get_node("Board/RoundOver/VictoryScreen/NextStageButton")
	exit_dungeon_button = get_node("Board/RoundOver/DefeatScreen/ExitDungeonButton")
	start_stage_button = get_node("StartStage")

func _connect_events():
	map_tiles.tile_clicked.connect(_try_select_any_unit_on_tile)
	board.round_over.connect(_on_round_over)
	next_stage_button.pressed.connect(_setup_stage)
	exit_dungeon_button.pressed.connect(_exit_dungeon)
	start_stage_button.pressed.connect(_start_stage)

# Unit selection
func _try_select_any_unit_on_tile(tile: Tile):
	var tile_pos: Vector2 = tile.position + Vector2(50, 50)
	var friendly_instances: Array[Node] = get_node("Board/Units/FriendlyUnits").get_children()
	for unit in friendly_instances:
		if unit.position.is_equal_approx(tile_pos):
			_deselect_current_unit()
			_handle_in_game_unit_selected(unit)
			return

	var enemy_instances: Array[Node] = get_node("Board/Units/EnemyUnits").get_children()
	for unit in enemy_instances:
		if unit.position.is_equal_approx(tile_pos):
			_deselect_current_unit()
			_handle_in_game_unit_selected(unit)
			return

	_deselect_current_unit()

func _deselect_current_unit() -> void:
	if currently_selected_unit_entity_container != null:
		_set_highlight(currently_selected_unit_entity_container, false)
		currently_selected_unit_entity_container = null
	# Also clear any in-game highlight on raw Entity nodes
	for unit in get_node("Board/Units/FriendlyUnits").get_children():
		var h = unit.get_node_or_null("Highlight")
		if h:
			h.queue_free()
	for unit in get_node("Board/Units/EnemyUnits").get_children():
		var h = unit.get_node_or_null("Highlight")
		if h:
			h.queue_free()

func _set_highlight(container: EntityContainer, enabled: bool) -> void:
	var highlight: ColorRect = container.get_node_or_null("Highlight")
	if enabled and highlight == null:
		highlight = ColorRect.new()
		highlight.name = "Highlight"
		highlight.color = Color(1, 1, 0, 0.4)
		highlight.size = Vector2(100, 100)
		highlight.position = Vector2(-40, -40)
		highlight.z_index = 10
		container.add_child(highlight)
	elif not enabled and highlight != null:
		highlight.queue_free()
