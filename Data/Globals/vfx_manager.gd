extends Node

func _on_animation_finished(vfx: AnimatedSprite2D):
	vfx.queue_free()
	
## Always called when unit takes tamage
func flash_damage(sprite: Sprite2D) -> void:
	if sprite == null:
		return
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE

## Always called when unit takes damage from an attacks
func damage_effect(node_spawn: Node, vfx_dict: Dictionary = {}) -> void:
	if not vfx_dict.is_empty():
		var vfx_scene: PackedScene = vfx_dict["path"]
		var vfx_animation: String = vfx_dict["animation"]
		var vfx = vfx_scene.instantiate()
		vfx.scale = vfx_dict["scale"]
		node_spawn.add_child(vfx)
		vfx.play(vfx_animation)
		vfx.animation_finished.connect(_on_animation_finished.bind(vfx))

## Spawns one copy of the sprite scene on the centre of every tile in `tiles`,
## each rotated to point along `facing` so the effect reads the same in all 8
## directions. Use for multi-tile directional strikes where the art marks the
## exact tiles that got hit.
## `sprite_scene_dict` takes an optional "rotation_offset" (radians) describing
## which way the art points at rest — 0.0 for art that points +X, PI for -X.
func spawn_tile_vfx(
	node_spawn: Node2D,
	tiles: Array[Vector2i],
	facing: Vector2i,
	sprite_scene_dict: Dictionary
	):
	if sprite_scene_dict.is_empty() or tiles.is_empty():
		return

	var anim: String = sprite_scene_dict["animation"]
	var art_scale: Vector2 = sprite_scene_dict["scale"]
	var rotation_offset: float = sprite_scene_dict.get("rotation_offset", 0.0)
	var angle: float = Vector2(facing).angle() + rotation_offset

	for tile in tiles:
		var vfx: AnimatedSprite2D = sprite_scene_dict["path"].instantiate()
		node_spawn.add_child(vfx)
		vfx.rotation = angle
		vfx.scale = art_scale
		# Children are in the spawner's local space, so undo its board position.
		vfx.position = BoardGrid.tile_to_world(tile) - node_spawn.position
		vfx.play(anim)
		vfx.animation_finished.connect(_on_animation_finished.bind(vfx))

## Spawns a single copy of the sprite scene on the centre of `origin`, stretched
## so the art spans the whole square area the ability covers. Use for radial
## effects that read as one impact — a ground slam, a shockwave, a burst — where
## nine separate copies would read as nine separate hits.
## `radius` is in tiles and matches BoardGrid.get_tiles_around(), so radius 1
## covers the 3x3 block around the origin.
## `sprite_scene_dict` takes a "native_size" (px, the width of the frame at rest)
## describing how big the art is before stretching.
func spawn_area_vfx(
	node_spawn: Node2D,
	origin: Vector2i,
	radius: int,
	sprite_scene_dict: Dictionary
	):
	if sprite_scene_dict.is_empty():
		return

	var vfx: AnimatedSprite2D = sprite_scene_dict["path"].instantiate()
	node_spawn.add_child(vfx)

	# How wide the covered block is in world px, art is square so this is both axes.
	var span: float = (radius * 2 + 1) * BoardGrid.astar.cell_size.x
	var native_size: float = sprite_scene_dict.get("native_size", span)
	vfx.scale = Vector2.ONE * (span / native_size) * sprite_scene_dict["scale"]
	# Children are in the spawner's local space, so undo its board position.
	vfx.position = BoardGrid.tile_to_world(origin) - node_spawn.position
	vfx.play(sprite_scene_dict["animation"])
	vfx.animation_finished.connect(_on_animation_finished.bind(vfx))

func spawn_cone_vfx(
	node_spawn: Node,
	facing: Vector2i,
	sprite_scene_dict: Dictionary,
	CONE_DEPTH: int,
	TILE_SIZE: float,
	VFX_NATIVE_HALF_WIDTH: float,
	VFX_NATIVE_LENGTH: float
	):
	var vfx: AnimatedSprite2D = sprite_scene_dict["path"].instantiate()
	var anim: String = sprite_scene_dict["animation"]
	node_spawn.add_child(vfx)

	var dir: Vector2 = Vector2(facing).normalized()
	var is_diagonal: bool = facing.x != 0 and facing.y != 0
	var half_angle: float = deg_to_rad(35.0) if is_diagonal else deg_to_rad(45.0)

	# How far the cone actually reaches, in world px.
	# Chebyshev range means a diagonal cone is sqrt(2) longer.
	var reach: float = (CONE_DEPTH + 0.5) * TILE_SIZE
	if is_diagonal:
		reach *= sqrt(2.0)

	# 1. Angle — art points +X at rest, so facing.angle() is all you need.
	vfx.rotation = dir.angle()

	# 2. Scale — stretch length to reach, width to match the cone's half-angle.
	var art_scale: Vector2 = sprite_scene_dict["scale"]
	vfx.scale = Vector2(
		reach / VFX_NATIVE_LENGTH,
		(reach * tan(half_angle)) / VFX_NATIVE_HALF_WIDTH
	) * art_scale

	# 3. Pivot — slide the texture forward so the node origin sits on the apex.
	vfx.centered = true
	vfx.offset = Vector2(VFX_NATIVE_LENGTH * 0.5, 0.0)

	vfx.position = Vector2.ZERO  # = Paramander's tile centre
	vfx.play(anim)
	vfx.animation_finished.connect(_on_animation_finished.bind(vfx))
