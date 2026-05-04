extends Node2D
class_name MovmentComponent

@export var stop_range = 100

@onready var parent_entity: Entity = get_parent().get_parent()
@onready var timer: Timer = $Timer

var is_in_target_range: bool = false

func _ready() -> void:
	timer.wait_time = 1.1
	# Use the unit's own tile_position instead of the global debug value

func move_to_tile(target_tile: Vector2i):
	var parent_entity_tile = BoardGrid.world_to_tile(parent_entity.position)
	var next_pos = BoardGrid.move_towards_tile_destination(parent_entity_tile, target_tile)
	if next_pos != Vector2():
		BoardGrid.set_tile_solid(parent_entity_tile, false)
		parent_entity.position = next_pos
		BoardGrid.set_tile_solid(next_pos, true)

func move_to_target_tile(target: Entity) -> bool:
	var attack_range: int = 100
	if parent_entity.attack_component != null:
		attack_range = parent_entity.attack_component.attack_range

	var distance = parent_entity.position.distance_to(target.position)
	
	if distance <= attack_range:
		return true  # In range, don't move
	
	var target_tile: Vector2i = BoardGrid.world_to_tile(target.position)
	move_to_tile(target_tile)
	return false
