extends Node

const DIRECTIONS_8 := [
	Vector2i(0, -1),   # N
	Vector2i(1, -1),   # NE
	Vector2i(1, 0),    # E
	Vector2i(1, 1),    # SE
	Vector2i(0, 1),    # S
	Vector2i(-1, 1),   # SW
	Vector2i(-1, 0),   # W
	Vector2i(-1, -1)   # NW
]

var astar: AStarGrid2D
var debug_start_position = Vector2i(1, 1)
var debug_destination = Vector2i(7, 7)

func _init() -> void:
	astar = AStarGrid2D.new()
	astar.region = Rect2i(0, 0, 8, 8)
	astar.cell_size = Vector2(100, 100)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

func get_tiles_adjacent_wide(start_tile: Vector2i, target_tile: Vector2i) -> Array[Vector2i]:
	var target_a: Vector2i
	var target_b: Vector2i
	
	if target_tile.y > start_tile.y or target_tile.y < start_tile.y:
		target_a = target_tile - Vector2i(+1, 0)
		target_b = target_tile - Vector2i(-1, 0)
	elif (target_tile.x > start_tile.x) or (target_tile.x < start_tile.x):
		target_a = target_tile - Vector2i(0, +1)
		target_b = target_tile - Vector2i(0, -1)
	
	return [target_a, target_b]

func get_tiles_surrounding_target(target_tile: Vector2i) -> Array[Vector2i]:
	return [
		target_tile + Vector2i(0, +1),
		target_tile + Vector2i(+1, 0),
		target_tile + Vector2i(+1, +1),
		target_tile + Vector2i(0, -1),
		target_tile + Vector2i(-1, 0),
		target_tile + Vector2i(-1, -1),
		target_tile + Vector2i(+1, -1),
		target_tile + Vector2i(-1, +1),
	]

func get_tiles_two_behind(start_tile: Vector2i, target_tile: Vector2i) -> Array[Vector2i]:
	var target_a: Vector2i
	var target_b: Vector2i
	
	if target_tile.x > start_tile.x:
		target_a = target_tile - Vector2i(+1, 0)
		target_b = target_tile - Vector2i(+2, 0)
	elif target_tile.x < start_tile.x:
		target_a = target_tile - Vector2i(-1, 0)
		target_b = target_tile - Vector2i(-2, 0)
	elif target_tile.y > start_tile.y:
		target_a = target_tile - Vector2i(0, +1)
		target_b = target_tile - Vector2i(0, +2)
	elif target_tile.y < start_tile.y:
		target_a = target_tile - Vector2i(0, -1)
		target_b = target_tile - Vector2i(0, -2)
	
	return [target_a, target_b]

func get_neighbor_tile(tile: Vector2i, direction: Vector2i) -> Vector2i:
	return tile + direction

func move_towards_tile_destination(start_position: Vector2i, tile_destination: Vector2i) -> Vector2:
	var movment_index: int = 1
	var stop_range: int = 1
	
	var actual_destination = tile_destination
	if astar.is_point_solid(tile_destination):
		actual_destination = get_closest_walkable_tile_to(tile_destination, start_position)
	
	var path: PackedVector2Array = astar.get_point_path(start_position, actual_destination)
	if path.size() > stop_range:
		return path[movment_index] + Vector2(50, 50)
	return Vector2()

func get_closest_walkable_tile_to(target_tile: Vector2i, from_tile: Vector2i) -> Vector2i:
	# If the target itself is free, just use it
	if not astar.is_point_solid(target_tile):
		return target_tile
	
	# Search outward in increasing Manhattan distance
	var max_search_radius: int = 5
	var best_tile: Vector2i = target_tile
	var best_distance: float = INF
	
	for radius in range(1, max_search_radius + 1):
		for dx in range(-radius, radius + 1):
			for dy in range(-radius, radius + 1):
				if abs(dx) + abs(dy) != radius:
					continue  # Only check the ring at this exact radius
				var candidate: Vector2i = target_tile + Vector2i(dx, dy)
				if not astar.region.has_point(candidate):
					continue
				if astar.is_point_solid(candidate):
					continue
				var dist: float = from_tile.distance_to(candidate)
				if dist < best_distance:
					best_distance = dist
					best_tile = candidate
		if best_distance < INF:
			break  # Found something at this radius, no need to go further
	
	return best_tile

func world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(world_pos / astar.cell_size)

func tile_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile) * astar.cell_size + astar.cell_size / 2

func set_tile_solid(tile: Vector2i, solid: bool):
	astar.set_point_solid(tile, solid)
