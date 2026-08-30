extends Unit

const TILE_SIZE: float = 100.0
const VFX_NATIVE_LENGTH: float = 256.0      # apex → tip along the frame's X
const VFX_NATIVE_HALF_WIDTH: float = 256.0  # centreline → edge at the tip
const CONE_DEPTH: int = 4
const CONE_DAMAGE_MULTIPLIER: float = 5.0

var ability_sprite_scene = {
	"path": preload("res://Scenes/Animations/Skills/fire_breath.tscn"),
	"animation": "default",
	"scale": Vector2(1, 1),
	}

func _init() -> void:
	id = "paramander"
	passive_description = "Breathe fire in a cone in front of Paramander when he uses his weapon skill."
	base_health = 100
	attack_damage = 10
	attack_range = 200
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2
	is_player_unit = true

func _ready() -> void:
	super._ready()
	_info("paramander", "Paramander", "Team 1", "Team 2")

	# Hook into the weapon skill signal once the weapon slot is populated
	await get_tree().process_frame
	_connect_weapon_skill()

func _set_stats() -> void:
	health_component.set_stats(base_health * PlayerData.inner_sanctum.life)
	attack_component.set_stats_absolute(
		attack_damage * PlayerData.inner_sanctum.power,
		attack_range,
		base_critical_percent_chance,
		base_critical_damage_multiplier
	)

# ── Passive: connect to the weapon's use_weapon_skill signal ──────────────────
func _connect_weapon_skill():
	if weapon_slot_component == null:
		return
	var weapon: Entity = weapon_slot_component.weapon
	if weapon == null:
		return
	var wc: WeaponComponent = weapon.get_node_or_null("Components/WeaponComponent")
	if wc != null:
		wc.use_weapon_skill.connect(_on_weapon_skill_used)

func _on_weapon_skill_used(_targets: Array[Entity]):
	_fire_cone()

# ── Cone logic ────────────────────────────────────────────────────────────────
func _fire_cone():
	AudioManager.play_sfx_once(self, "res://Scenes/Units/PC/paramander/floraphonic-fireball-whoosh-5-179129.mp3")
	var my_tile: Vector2i = BoardGrid.world_to_tile(position)
	var facing: Vector2i = _get_facing_direction()

	var cone_tiles: Array[Vector2i] = _get_cone_tiles(my_tile, facing)

	var damage: int = int(attack_component.get_total_attack_damage() * CONE_DAMAGE_MULTIPLIER)
	var enemies: Array[Node] = get_tree().get_nodes_in_group(hostile_team)

	for entity in enemies:
		if entity is Entity and entity.health_component != null:
			var entity_tile: Vector2i = BoardGrid.world_to_tile(entity.position)
			if entity_tile in cone_tiles:
				entity.health_component.take_damage_flat(self, damage, false)
				
	_spawn_cone_vfx(facing)

func _spawn_cone_vfx(facing: Vector2i) -> void:
	var vfx: AnimatedSprite2D = ability_sprite_scene["path"].instantiate()
	var anim: String = ability_sprite_scene["animation"]
	add_child(vfx)

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
	var art_scale: Vector2 = ability_sprite_scene["scale"]
	vfx.scale = Vector2(
		reach / VFX_NATIVE_LENGTH,
		(reach * tan(half_angle)) / VFX_NATIVE_HALF_WIDTH
	) * art_scale

	# 3. Pivot — slide the texture forward so the node origin sits on the apex.
	vfx.centered = true
	vfx.offset = Vector2(VFX_NATIVE_LENGTH * 0.5, 0.0)

	vfx.position = Vector2.ZERO  # = Paramander's tile centre
	#vfx.z_index = 5
	vfx.play(anim)
	vfx.animation_finished.connect(_on_animation_finished.bind(vfx))

func _on_animation_finished(vfx: AnimatedSprite2D):
	vfx.queue_free()

func _get_facing_direction() -> Vector2i:
	if targeting_component != null and targeting_component.target != null:
		var target_tile: Vector2i = BoardGrid.world_to_tile(targeting_component.target.position)
		var my_tile: Vector2i = BoardGrid.world_to_tile(position)
		var diff: Vector2i = target_tile - my_tile
		if diff == Vector2i.ZERO:
			return Vector2i(1, 0)
		# Snap each axis independently to -1, 0, or 1
		return Vector2i(sign(diff.x), sign(diff.y))
	return Vector2i(1, 0)

func _get_cone_tiles(origin: Vector2i, forward: Vector2i) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	var fwd_f: Vector2 = Vector2(forward).normalized()
	var is_diagonal: bool = forward.x != 0 and forward.y != 0
	var half_angle: float = deg_to_rad(35.0) if is_diagonal else deg_to_rad(45.0)
	for dx in range(-CONE_DEPTH, CONE_DEPTH + 1):
		for dy in range(-CONE_DEPTH, CONE_DEPTH + 1):
			var tile: Vector2i = origin + Vector2i(dx, dy)
			if not BoardGrid.astar.region.has_point(tile):
				continue
			var offset: Vector2 = Vector2(tile - origin)
			if offset == Vector2.ZERO:
				continue
			if max(abs(dx), abs(dy)) > CONE_DEPTH:
				continue
			var dot: float = offset.normalized().dot(fwd_f)
			var angle: float = acos(clamp(dot, -1.0, 1.0))
			if angle <= half_angle:
				tiles.append(tile)
	return tiles
