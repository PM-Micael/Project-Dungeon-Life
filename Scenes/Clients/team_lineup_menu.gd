# Scenes/Clients/team_lineup_menu.gd
extends Node2D
class_name TeamLineupMenu

@onready var board: GameBoard = get_node("Board")
@onready var map_tiles_scene: MapTiles = get_node_or_null("Board/MapTiles")
@onready var ui_scene = get_node_or_null("UI")
@onready var unit_loadout_frame: UnitLoadoutFrame = get_node("UI/Inventory/UnitLoadoutFrame")
@onready var currently_selected_unit_entity_container: EntityContainer = null

var game_on: bool = false

func _ready() -> void:
	LocalData.initialize_data(ui_scene, board)
	_setup()
	map_tiles_scene.tile_clicked.connect(_on_tile_clicked)
	unit_loadout_frame.show_stats = false
	place_friendly_characters_board()
	place_enemy_units_dev()
	board.round_over.connect(_on_round_over)

func _setup():
	var window = get_window()
	window.borderless = true


# ─── Unit Placement ───────────────────────────────────────────────────────────

func place_friendly_characters_board():
	var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")

	var friendly_side = map_tiles_scene.get_node("FriendlySide")
	var front_row = friendly_side.get_node("Row")
	var tiles = front_row.get_children()

	var loop_itteration: int = 0
	for c in DungeonData.dungeon_team:
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
		entity_container_instance.name = "EntityContainer_" + str(loop_itteration + 1)
		entity_container_instance.entity = c

		var tile_position: Vector2 = tiles[loop_itteration].position + map_tiles_scene.position + Vector2(50, 50)
		entity_container_instance.position = tile_position
		c.starting_position = entity_container_instance.position

		var sprite_instance = Sprite2D.new()
		sprite_instance.name = "Sprite2D"
		sprite_instance.texture = c.get_node("Sprite2D").texture
		sprite_instance.scale = Vector2(0.15, 0.15)

		entity_container_instance.add_child(sprite_instance)
		board.get_node("Characters/FriendlyUnits").add_child(entity_container_instance)

		loop_itteration += 1

func place_enemy_units_dev():
	var enemy_formation_index: int = randi_range(0, DungeonData.enemy_formations.size() - 1)
	var enemy_formation: Array = DungeonData.enemy_formations[enemy_formation_index]
	var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")

	var loop_itteration: int = 0
	for e in enemy_formation:
		var enemy_type: String = e["type"]
		var enemy_position: Vector2 = e["position"]
		var enemy_scene: PackedScene = load("res://Scenes/Units/" + enemy_type + ".tscn")
		var enemy_instance: Entity = enemy_scene.instantiate()
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()

		entity_container_instance.name = "EntityContainer_" + str(loop_itteration + 1)
		entity_container_instance.entity = enemy_instance
		entity_container_instance.position = enemy_position
		enemy_instance.starting_position = entity_container_instance.position

		var sprite_instance = Sprite2D.new()
		sprite_instance.name = "Sprite2D"
		sprite_instance.texture = enemy_instance.get_node("Sprite2D").texture
		sprite_instance.scale = Vector2(0.15, 0.15)

		entity_container_instance.add_child(sprite_instance)
		board.get_node("Characters/EnemyUnits").add_child(entity_container_instance)
		board.enemy_units.append(enemy_instance)

		loop_itteration += 1


# ─── Game State ───────────────────────────────────────────────────────────────

func start_game() -> void:
	game_on = true
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
	var friendly_instances: Array[Node] = get_node("Board/Characters/FriendlyUnits").get_children()
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
	var instances: Array[Node] = get_node("Board/Characters/FriendlyUnits").get_children()
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
	var friendly_instances: Array[Node] = get_node("Board/Characters/FriendlyUnits").get_children()
	for unit in friendly_instances:
		if unit.position.is_equal_approx(tile_pos):
			_deselect_current_unit()
			_handle_in_game_unit_selected(unit)
			return

	var enemy_instances: Array[Node] = get_node("Board/Characters/EnemyUnits").get_children()
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
	for unit in get_node("Board/Characters/FriendlyUnits").get_children():
		var h = unit.get_node_or_null("Highlight")
		if h:
			h.queue_free()
	for unit in get_node("Board/Characters/EnemyUnits").get_children():
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

func change_board_layout():
	return
