extends Node2D
class_name CollisionComponent

static var occupied_positions: Dictionary = {}

@onready var parent_entity: Entity = get_parent().get_parent()

func _ready() -> void:
	_register_position(parent_entity.global_position)

func _exit_tree() -> void:
	_unregister_position(parent_entity.global_position)

func is_position_free(pos: Vector2) -> bool:
	return not occupied_positions.has(pos) or occupied_positions[pos] == parent_entity

func move_to(new_pos: Vector2) -> void:
	_unregister_position(parent_entity.global_position)
	parent_entity.global_position = new_pos
	_register_position(new_pos)

func _register_position(pos: Vector2) -> void:
	occupied_positions[pos] = parent_entity

func _unregister_position(pos: Vector2) -> void:
	if occupied_positions.get(pos) == parent_entity:
		occupied_positions.erase(pos)
