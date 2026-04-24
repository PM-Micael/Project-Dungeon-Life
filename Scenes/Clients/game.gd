extends Node2D

@onready var game_board_node: GameBoard = get_node("Board")
@onready var round_over_node: Node2D = get_node("RoundOver")
@onready var map_tiles_scene: MapTiles = get_node_or_null("Board/MapTiles")
@onready var unit_loadout_frame: UnitLoadoutFrame = get_node("UI/InfoClient/UnitLoadoutFrame")
@onready var currently_selected_unit_entity: Entity = null

var game_on: bool = false

func _ready() -> void:
	_fill_board_info_frame()
	game_board_node.round_over.connect(_on_round_over)
	map_tiles_scene.tile_clicked.connect(_on_tile_clicked)

func _on_round_over():
	round_over_node.visible = true

func _fill_board_info_frame():
	for u in game_board_node.enemy_units:
		var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
		var instance: EntityContainer = entity_container_scene.instantiate()
		
		instance.entity = u
		
		get_node("UI/InfoClient/MainBackround/BoardUnits").add_child(instance)

func _on_tile_clicked(tile: Tile) -> void:
	_try_select_unit_on_tile(tile)

func _try_select_unit_on_tile(tile: Tile) -> void:
	var tile_pos: Vector2 = tile.position + Vector2(50, 50)
	
	# Check friendly units
	var friendly_instances: Array[Node] = get_node("Board/Characters/FriendlyUnits").get_children()
	for unit in friendly_instances:
		if unit.position.is_equal_approx(tile_pos):
			_handle_unit_selected(unit)
			return
	
	# Check enemy units
	var enemy_instances: Array[Node] = get_node("Board/Characters/EnemyUnits").get_children()
	for unit in enemy_instances:
		if unit.position.is_equal_approx(tile_pos):
			_handle_unit_selected(unit)
			return
	
	# Clicked empty tile — deselect
	if currently_selected_unit_entity != null:
		_set_highlight(currently_selected_unit_entity, false)
		currently_selected_unit_entity = null

func _handle_unit_selected(unit: Node2D) -> void:
	if unit == currently_selected_unit_entity:
		_set_highlight(unit, false)
		currently_selected_unit_entity = null
		return
	
	if currently_selected_unit_entity != null:
		_set_highlight(currently_selected_unit_entity, false)
	
	currently_selected_unit_entity = unit
	_set_highlight(unit, true)
	unit_loadout_frame.unit_entity = unit as Entity

func _set_highlight(unit: Entity, enabled: bool) -> void:
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
