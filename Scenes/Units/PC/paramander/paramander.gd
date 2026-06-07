extends Unit

# ── Passive tuning ────────────────────────────────────────────────────────────
# How many tiles deep the cone reaches in front of Paramander
const CONE_DEPTH: int = 4
# Damage dealt to each enemy inside the cone (flat, scales with attack damage)
const CONE_DAMAGE_MULTIPLIER: float = 0.5

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
	_set_stats()
	_info("paramander", "Paramander", "Team 1", "Team 2")

	# Hook into the weapon skill signal once the weapon slot is populated
	await get_tree().process_frame
	_connect_weapon_skill()

func _set_stats():
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
	var weapon = weapon_slot_component.get_child(0)
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

	# Determine the facing direction toward Paramander's current target
	var facing: Vector2i = _get_facing_direction()

	# Build the set of tiles inside the cone in front of Paramander.
	# For a forward-facing cone we include tiles that are ahead (positive dot
	# product with facing) within CONE_DEPTH range, excluding the wearer's tile.
	var cone_tiles: Array[Vector2i] = _get_cone_tiles(my_tile, facing)

	var damage: int = int(attack_component.get_total_attack_damage() * CONE_DAMAGE_MULTIPLIER)
	var enemies: Array[Node] = get_tree().get_nodes_in_group(hostile_team)

	for entity in enemies:
		if entity is Entity and entity.health_component != null:
			var entity_tile: Vector2i = BoardGrid.world_to_tile(entity.position)
			if entity_tile in cone_tiles:
				entity.health_component.take_damage_flat(self, damage, false)
				print("Paramander cone hit: " + entity.display_name + " for " + str(damage))

# Returns the direction Paramander is "facing" as a unit tile vector.
# Falls back to Vector2i.RIGHT (toward enemy side) if no target exists.
func _get_facing_direction() -> Vector2i:
	if targeting_component != null and targeting_component.target != null:
		var target_tile: Vector2i = BoardGrid.world_to_tile(targeting_component.target.position)
		var my_tile: Vector2i = BoardGrid.world_to_tile(position)
		var diff: Vector2i = target_tile - my_tile
		# Snap to the dominant axis so the cone stays grid-aligned
		if abs(diff.x) >= abs(diff.y):
			return Vector2i(sign(diff.x), 0)
		else:
			return Vector2i(0, sign(diff.y))
	# Default: face right (toward the enemy side of the board)
	return Vector2i(1, 0)

# Returns all tiles within a forward-facing cone of CONE_DEPTH depth.
# The cone widens by ±1 tile perpendicular for each step forward.
func _get_cone_tiles(origin: Vector2i, forward: Vector2i) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	# Perpendicular axis
	var perp: Vector2i = Vector2i(-forward.y, forward.x)

	for depth in range(1, CONE_DEPTH + 1):
		# At each depth the cone width is ±(depth-1) tiles wide
		for spread in range(-(depth - 1), depth):
			var tile: Vector2i = origin + forward * depth + perp * spread
			if BoardGrid.astar.region.has_point(tile):
				tiles.append(tile)

	return tiles
