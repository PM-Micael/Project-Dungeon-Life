# Scenes/Clients/team_lineup_menu.gd
extends Node2D
class_name TeamLineupMenu

@onready var board: GameBoard = get_node("Board")
@onready var map_tiles_scene: MapTiles = get_node_or_null("Board/MapTiles")
@onready var ui_scene = get_node_or_null("UI")
@onready var unit_loadout_frame: UnitLoadoutFrame = get_node("UI/Inventory/UnitLoadoutFrame")
@onready var next_stage_button: Button = get_node("Board/RoundOver/VictoryScreen/NextStageButton")
@onready var currently_selected_unit_entity_container: EntityContainer = null

var game_on: bool = false
var current_room: int = 4

func _ready() -> void:
	LocalData.initialize_data(ui_scene, board)
	_window_setup()
	_connect_events()
	_setup_stage()

func _connect_events():
	map_tiles_scene.tile_clicked.connect(_on_tile_clicked)
	board.round_over.connect(_on_round_over)
	next_stage_button.pressed.connect(_setup_stage)

func _window_setup():
	var window = get_window()
	window.borderless = true

func _setup_stage():
	board.victory_screen.visible = false
	board.defeat_screen.visible = false
	board.friendly_units.clear()
	board.enemy_units.clear()
	_place_friendly_units()
	_place_enemy_units()
	unit_loadout_frame.show_stats = false

# ─── Unit Placement ───────────────────────────────────────────────────────────

func _place_friendly_units():
	var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
	
	for u in PlayerData.dungeon_team_formation:
		var unit_name: String = u["unit_name"]
		var unit_starting_position = u["starting_position"]
		var weapon_id = u["weapon_id"]
		
		var unit_scene: PackedScene = load("res://Scenes/Units/PC/" + unit_name + "/" + unit_name + ".tscn")
		var unit_instance: Unit = unit_scene.instantiate()
		
		if weapon_id != "":
			var weapon_scene: PackedScene = load("res://Scenes/Weapons/"+weapon_id+"/"+weapon_id+".tscn")
			var weapon_instance: Entity = weapon_scene.instantiate()
			var weapon_slot = unit_instance.get_node("Components/WeaponSlotComponent")
			weapon_slot.add_child(weapon_instance)
		
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
		
		entity_container_instance.name = "EntityContainer_" + unit_name
		entity_container_instance.entity = unit_instance
		entity_container_instance.position = unit_starting_position
		entity_container_instance.scale = unit_instance.scale
		unit_instance.starting_position = entity_container_instance.position
		
		board.get_node("Units/FriendlyUnits").add_child(entity_container_instance)
		board.friendly_units.append(unit_instance)

func _place_enemy_units():
	var room_key: String = "room_" + str(current_room)
	var formations_dict: Dictionary = DungeonData.dungeon_wave_formations["putrid_layers"][room_key][0]
	
	var formation_count: int = formations_dict.size()
	var enemy_formation_index: int = randi_range(0, formation_count - 1)
	
	var enemy_formation: Array = formations_dict["formation_" + str(enemy_formation_index + 1)]
	var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")

	var loop_itteration: int = 0
	for e in enemy_formation:
		var enemy_type: String = e["type"]
		var enemy_position: Vector2 = e["position"]
		var enemy_scene: PackedScene = load("res://Scenes/Units/NPC/" + enemy_type + "/" + enemy_type + ".tscn")
		var enemy_instance: Unit = enemy_scene.instantiate()
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()

		entity_container_instance.name = "EntityContainer_" + str(loop_itteration + 1)
		entity_container_instance.entity = enemy_instance
		entity_container_instance.position = enemy_position
		entity_container_instance.scale = enemy_instance.scale
		enemy_instance.starting_position = entity_container_instance.position

		board.get_node("Units/EnemyUnits").add_child(entity_container_instance)
		board.enemy_units.append(enemy_instance)

		loop_itteration += 1


# ─── Game State ───────────────────────────────────────────────────────────────

func start_game() -> void:
	game_on = true
	board.game_on = true
	unit_loadout_frame.show_stats = true
	_deselect_current_unit()

func _on_round_over(player_won: bool) -> void:
	game_on = false
	# TODO: show victory/defeat UI inside team_lineup_menu


# ─── Input / Tile Clicks ─────────────────────────────────────────────────────

func _on_tile_clicked(tile: Tile) -> void:
	if game_on:
		_try_select_any_unit_on_tile(tile)
	else:
		if currently_selected_unit_entity_container == null:
			_try_select_friendly_unit_on_tile(tile)
		else:
			_move_selected_unit_to_tile(tile)


# ─── Lineup Phase (game_on = false) ──────────────────────────────────────────

func _try_select_friendly_unit_on_tile(tile: Tile) -> void:
	var tile_pos: Vector2 = tile.position + Vector2(50, 50)
	var friendly_instances: Array[Node] = get_node("Board/Units/FriendlyUnits").get_children()
	for container in friendly_instances:
		if container.position.is_equal_approx(tile_pos):
			if container == currently_selected_unit_entity_container:
				_deselect_current_unit()
				return
			_deselect_current_unit()
			currently_selected_unit_entity_container = container
			_set_highlight(container, true)
			unit_loadout_frame.unit_entity = container.entity
			return

func _move_selected_unit_to_tile(tile: Tile) -> void:
	var new_pos: Vector2 = tile.position + Vector2(50, 50)
	var instances: Array[Node] = get_node("Board/Units/FriendlyUnits").get_children()
	for container in instances:
		if container.position.is_equal_approx(new_pos):
			# Tile occupied — swap selection to that unit instead
			_deselect_current_unit()
			currently_selected_unit_entity_container = container
			_set_highlight(container, true)
			unit_loadout_frame.unit_entity = container.entity
			return

	_set_highlight(currently_selected_unit_entity_container, false)
	currently_selected_unit_entity_container.position = new_pos
	currently_selected_unit_entity_container.entity.starting_position = new_pos
	currently_selected_unit_entity_container = null


# ─── Game Phase (game_on = true) ─────────────────────────────────────────────

func _try_select_any_unit_on_tile(tile: Tile) -> void:
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

func _handle_in_game_unit_selected(unit: Node2D) -> void:
	# After game starts, FriendlyUnits/EnemyUnits contain raw Entity nodes,
	# not EntityContainers — so we resolve the Entity directly.
	var entity: Entity = unit as Entity
	if entity == null and unit is EntityContainer:
		entity = (unit as EntityContainer).entity

	if entity == null:
		return

	# Deselect previous
	if currently_selected_unit_entity_container != null:
		_set_highlight(currently_selected_unit_entity_container, false)
		currently_selected_unit_entity_container = null

	_set_highlight_node(unit, true)
	unit_loadout_frame.unit_entity = entity

func _set_highlight_node(unit: Node2D, enabled: bool) -> void:
	var highlight: ColorRect = unit.get_node_or_null("Highlight")
	if enabled and highlight == null:
		highlight = ColorRect.new()
		highlight.name = "Highlight"
		highlight.color = Color(1, 1, 0, 0.4)
		highlight.size = Vector2(500, 500)
		highlight.position = Vector2(-250, -250)
		highlight.z_index = 10
		unit.add_child(highlight)
	elif not enabled and highlight != null:
		highlight.queue_free()


# ─── Helpers ─────────────────────────────────────────────────────────────────

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
		highlight.size = Vector2(80, 80)
		highlight.position = Vector2(-40, -40)
		highlight.z_index = 10
		container.add_child(highlight)
	elif not enabled and highlight != null:
		highlight.queue_free()
