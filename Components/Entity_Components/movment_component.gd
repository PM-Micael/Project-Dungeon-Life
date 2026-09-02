extends Node2D
class_name MovmentComponent

@export var stop_range = 100

@onready var parent_entity: Entity = get_parent().get_parent()
@onready var timer: Timer = $Timer

var is_in_target_range: bool = false

func _ready() -> void:
	timer.wait_time = 1.1
	# Use the unit's own tile_position instead of the global debug value

func _physics_process(_delta: float) -> void:
	movment_action()

func movment_action():
	if timer.time_left <= 0.1 :
		if parent_entity.is_stunned:
			return
		
		if parent_entity.targeting_component == null:
			return
		
		var targets = parent_entity.targeting_component.select_closest_target(parent_entity.hostile_team)
		
		if parent_entity.attack_component != null:
			parent_entity.attack_component.in_target_attack_range = move_to_target_tile(targets[0])
		else:
			move_to_target_tile(targets[0])
		
		timer.start()

func move_to_tile(target_tile: Vector2i):
	var parent_entity_tile = BoardGrid.world_to_tile(parent_entity.position)
	BoardGrid.set_tile_solid(parent_entity_tile, false)
	var next_pos = BoardGrid.move_towards_tile_destination(parent_entity_tile, target_tile)
	if next_pos != Vector2():
		parent_entity.position = next_pos
		BoardGrid.set_tile_solid(BoardGrid.world_to_tile(next_pos), true)

func move_to_target_tile(target: Entity) -> bool:
	if parent_entity.attack_component != null:
		stop_range = parent_entity.attack_component.attack_range
	else:
		stop_range = 100
		
	var distance = parent_entity.position.distance_to(target.position)
	
	var diagonal_range = stop_range * sqrt(2)
	if distance <= diagonal_range:
		return true  # In attack range, don't move
	
	var target_tile: Vector2i = BoardGrid.world_to_tile(target.position)
	move_to_tile(target_tile)
	return false
