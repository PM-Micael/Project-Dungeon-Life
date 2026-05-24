# Handles run flow: stage setup, game state, inventory, and reacting to board events
extends Node2D
class_name RunManager

@onready var inner_sanctum_scene = preload("res://Scenes/Clients/Upgrades/inner_sanctum.tscn")

var board_window: BoardWindow
var inventory: Inventory
var inner_sanctum: InnerSanctum
var unit_loadout_frame: UnitLoadoutFrame
var game_on: bool = false

func _ready() -> void:
	# board_window is added as a child by main_client, wait for it
	board_window = get_node("BoardWindow")
	unit_loadout_frame = get_node("Inventory/UnitLoadoutFrame")

	board_window.unit_selected.connect(_on_unit_selected)
	board_window.unit_deselected.connect(_on_unit_deselected)
	board_window.round_over.connect(_on_round_over)
	board_window.next_stage_button.pressed.connect(_setup_stage)
	board_window.exit_dungeon_button.pressed.connect(_exit_dungeon)
	board_window.start_stage_button.pressed.connect(_start_stage)

	_setup_stage()
	DungeonData.check_and_merge_backpack_items()

	if PlayerData.settings.auto_advance:
		await get_tree().create_timer(0.5).timeout
		start_game()

# ─── Unit Selection (from BoardWindow) ───────────────────────────────────────

func _on_unit_selected(entity: Entity) -> void:
	unit_loadout_frame.unit_entity = entity
	unit_loadout_frame.show_stats = true

func _on_unit_deselected() -> void:
	unit_loadout_frame.unit_entity = null

# ─── Stage Setup ─────────────────────────────────────────────────────────────

func _setup_stage():
	var board = board_window.board
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
		board_window.start_stage_button.pressed.emit()

func _start_stage():
	var board = board_window.board
	PlayerData.save_dungeon_team_as_formation(board.friendly_units)
	for f in get_node("BoardWindow/Board/Units/FriendlyUnits").get_children():
		f.free()
	for e in get_node("BoardWindow/Board/Units/EnemyUnits").get_children():
		e.free()
	board.place_friendly_units_on_board()
	board.place_enemy_units_on_board()
	start_game()

func _exit_dungeon():
	board_window.board.defeat_screen.visible = false
	DungeonData.reset_backpack()
	PlayerData.reset_dungeon_run_data(DungeonData.Zone.PUTRID_LAYERS)
	inventory.fill_backpack_frame()
	add_inner_sanctum_scene()

# ─── Game State ───────────────────────────────────────────────────────────────

func start_game() -> void:
	game_on = true
	board_window.set_game_on(true)
	unit_loadout_frame.show_stats = true

func _on_round_over(player_won: bool) -> void:
	game_on = false

# ─── Inner Sanctum ────────────────────────────────────────────────────────────

func add_inner_sanctum_scene():
	var existing_board = get_node_or_null("BoardWindow/Board")
	if existing_board != null:
		existing_board.queue_free()
	var instance = inner_sanctum_scene.instantiate()
	add_child(instance)
	inner_sanctum = get_node("InnerSanctum")
	inner_sanctum.dungeon_button.pressed.connect(_ready)
