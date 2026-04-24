extends Node2D

@onready var game_board_node: GameBoard = get_node("Board")
@onready var round_over_node: Node2D = get_node("RoundOver")

var game_on: bool = false

func _ready() -> void:
	_fill_board_info_frame()
	game_board_node.round_over.connect(_on_round_over)

func _on_round_over():
	round_over_node.visible = true

func _fill_board_info_frame():
	for u in game_board_node.enemy_units:
		var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
		var instance: EntityContainer = entity_container_scene.instantiate()
		
		instance.entity = u
		
		get_node("UI/InfoClient/MainBackround/BoardUnits").add_child(instance)
