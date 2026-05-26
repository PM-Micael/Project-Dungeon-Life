# Handles run flow: stage setup, game state, unit selection, inventory sync
extends Node2D
class_name RunManager

@onready var inner_sanctum_scene = preload("res://Scenes/Clients/Upgrades/inner_sanctum.tscn")

@onready var board_window: Window = get_node("BoardWindow")
@onready var board: GameBoard = get_node("BoardWindow/Board")
@onready var map_tiles: MapTiles = get_node("BoardWindow/Board/MapTiles")
@onready var inventory: Inventory = get_node("InventoryWindow/UI/Inventory")
@onready var unit_loadout_frame: UnitLoadoutFrame = get_node("InventoryWindow/UI/Inventory/UnitLoadoutFrame")

@onready var next_stage_button: Button = get_node("BoardWindow/Board/RoundOver/VictoryScreen/NextStageButton")
@onready var exit_dungeon_button: Button = get_node("BoardWindow/Board/RoundOver/DefeatScreen/ExitDungeonButton")
@onready var start_stage_button: Button = get_node("BoardWindow/StartStage")

var inner_sanctum: InnerSanctum
var currently_selected_unit_entity_container: EntityContainer
var game_on: bool = false

func _ready() -> void:
	await PlayerData.player_data_loaded
	_connect_events()
	_setup_stage()
	DungeonData.check_and_merge_backpack_items()

	if PlayerData.settings.auto_advance:
		await get_tree().create_timer(0.5).timeout
		start_game()

# ─── Connect Events ───────────────────────────────────────────────────────────

func _connect_events():
	map_tiles.tile_clicked.connect(_on_tile_clicked)
	board.round_over.connect(_on_round_over)
	next_stage_button.pressed.connect(_setup_stage)
	exit_dungeon_button.pressed.connect(_exit_dungeon)
	start_stage_button.pressed.connect(_start_stage)

# ─── Stage Setup ─────────────────────────────────────────────────────────────

func _setup_stage():
	board.victory_screen.visible = false
	board.defeat_screen.visible = false
	board.friendly_units.clear()
	board.enemy_units.clear()
	board._place_friendly_units()
	board._place_enemy_units()
	unit_loadout_frame.show_stats = false
	print("Room = " + str(PlayerData.dungeon_room_putrid_layers))

	if PlayerData.settings.auto_advance:
		await get_tree().create_timer(0.5).timeout
		start_stage_button.pressed.emit()

func _start_stage():
	PlayerData.save_dungeon_team_as_formation(board.friendly_units)
	for f in get_node("BoardWindow/Board/Units/FriendlyUnits").get_children():
		f.free()
	for e in get_node("BoardWindow/Board/Units/EnemyUnits").get_children():
		e.free()
	board.place_friendly_units_on_board()
	board.place_enemy_units_on_board()
	start_game()

func _exit_dungeon():
	board.defeat_screen.visible = false
	DungeonData.reset_backpack()
	PlayerData.reset_dungeon_run_data(DungeonData.Zone.PUTRID_LAYERS)
	inventory.fill_backpack_frame()
	add_inner_sanctum_scene()

# ─── Game State ───────────────────────────────────────────────────────────────

func start_game() -> void:
	game_on = true
	board.game_on = true
	unit_loadout_frame.show_stats = true
	_deselect_current_unit()

func _on_round_over(player_won: bool) -> void:
	game_on = false

# ─── Input / Tile Clicks ─────────────────────────────────────────────────────

func _on_tile_clicked(tile: Tile) -> void:
	if game_on:
		_try_select_any_unit_on_tile(tile)
	else:
		if currently_selected_unit_entity_container == null:
			_try_select_friendly_unit_on_tile(tile)
		else:
			_move_selected_unit_to_tile(tile)

# ─── Lineup Phase ─────────────────────────────────────────────────────────────

func _try_select_friendly_unit_on_tile(tile: Tile) -> void:
	var tile_pos: Vector2 = tile.position + Vector2(50, 50)
	for container in get_node("BoardWindow/Board/Units/FriendlyUnits").get_children():
		if container.position.is_equal_approx(tile_pos):
			if container == currently_selected_unit_entity_container:
				_deselect_current_unit()
				return
			_deselect_current_unit()
			currently_selected_unit_entity_container = container
			_set_highlight(container, true)
			unit_loadout_frame.unit_entity = container.entity
			return
	_deselect_current_unit()

func _move_selected_unit_to_tile(tile: Tile) -> void:
	var new_pos: Vector2 = tile.position + Vector2(50, 50)
	for container in get_node("BoardWindow/Board/Units/FriendlyUnits").get_children():
		if container.position.is_equal_approx(new_pos):
			_deselect_current_unit()
			currently_selected_unit_entity_container = container
			_set_highlight(container, true)
			unit_loadout_frame.unit_entity = container.entity
			return
	_set_highlight(currently_selected_unit_entity_container, false)
	currently_selected_unit_entity_container.position = new_pos
	currently_selected_unit_entity_container.entity.starting_position = new_pos
	currently_selected_unit_entity_container = null

# ─── Game Phase ───────────────────────────────────────────────────────────────

func _try_select_any_unit_on_tile(tile: Tile) -> void:
	var tile_pos: Vector2 = tile.position + Vector2(50, 50)
	for unit in get_node("BoardWindow/Board/Units/FriendlyUnits").get_children():
		if unit.position.is_equal_approx(tile_pos):
			_deselect_current_unit()
			_handle_in_game_unit_selected(unit)
			return
	for unit in get_node("BoardWindow/Board/Units/EnemyUnits").get_children():
		if unit.position.is_equal_approx(tile_pos):
			_deselect_current_unit()
			_handle_in_game_unit_selected(unit)
			return
	_deselect_current_unit()

func _handle_in_game_unit_selected(unit: Node2D) -> void:
	var entity: Entity = unit as Entity
	if entity == null and unit is EntityContainer:
		entity = (unit as EntityContainer).entity
	if entity == null:
		return
	_set_highlight_node(unit, true)
	unit_loadout_frame.unit_entity = entity

# ─── Helpers ─────────────────────────────────────────────────────────────────

func _deselect_current_unit() -> void:
	if currently_selected_unit_entity_container != null:
		_set_highlight(currently_selected_unit_entity_container, false)
		currently_selected_unit_entity_container = null
	for unit in get_node("BoardWindow/Board/Units/FriendlyUnits").get_children():
		var h = unit.get_node_or_null("Highlight")
		if h: h.queue_free()
	for unit in get_node("BoardWindow/Board/Units/EnemyUnits").get_children():
		var h = unit.get_node_or_null("Highlight")
		if h: h.queue_free()

func _set_highlight(container: EntityContainer, enabled: bool) -> void:
	var highlight: ColorRect = container.get_node_or_null("Highlight")
	if enabled and highlight == null:
		highlight = ColorRect.new()
		highlight.name = "Highlight"
		highlight.color = Color(1, 1, 0, 0.4)
		highlight.size = Vector2(100, 100)
		highlight.position = Vector2(-50, -50)
		highlight.z_index = 10
		container.add_child(highlight)
	elif not enabled and highlight != null:
		highlight.queue_free()

func _set_highlight_node(unit: Node2D, enabled: bool) -> void:
	var highlight: ColorRect = unit.get_node_or_null("Highlight")
	if enabled and highlight == null:
		highlight = ColorRect.new()
		highlight.name = "Highlight"
		highlight.color = Color(1, 1, 0, 0.4)
		highlight.size = Vector2(100, 100)
		highlight.position = Vector2(-50, -50)
		highlight.z_index = 10
		unit.add_child(highlight)
	elif not enabled and highlight != null:
		highlight.queue_free()

# ─── Inner Sanctum ────────────────────────────────────────────────────────────

func add_inner_sanctum_scene():
	var existing_board = get_node_or_null("BoardWindow/Board")
	if existing_board != null:
		existing_board.queue_free()
	var instance = inner_sanctum_scene.instantiate()
	board_window.add_child(instance)
	inner_sanctum = get_node("BoardWindow/InnerSanctum")
	inner_sanctum.dungeon_button.pressed.connect(_ready)
