extends Node

var astar: AStarGrid2D
var debug_start_position = Vector2i(1, 1)
var debug_destination = Vector2i(7, 7)

func _init() -> void:
	astar = AStarGrid2D.new()
	astar.region = Rect2i(0, 0, 8, 8)
	astar.cell_size = Vector2(100, 100)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

func move_towards_tile_destination(
	start_position: Vector2i,
	tile_destination: Vector2i
	) -> Vector2:
	var movment_index: int = 1
	var stop_range: int = 1
	var path = astar.get_point_path(start_position, tile_destination)
	if path.size() > stop_range:
		#print("Path: ", path)
		#print("Destination: ", destination)
		return path[movment_index] + Vector2(50, 50)
	return Vector2()

func world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(world_pos / astar.cell_size)

func set_tile_solid(tile: Vector2i, solid: bool) -> void:
	astar.set_point_solid(tile, solid)
