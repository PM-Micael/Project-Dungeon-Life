extends Entity

@export var basic_attack_damage: int = 2

func _init() -> void:
	id = "rumble_gloves"

func _ready() -> void:
	name = "rumble_gloves"
	display_name = "Rumble Gloves"
	weapon_component.set_stats_absolute(basic_attack_damage)
	weapon_component.use_weapon_skill.connect(_weapon_skill)

func _calculate_damage() -> int:
	return 2

func _weapon_skill(targets: Array[Entity]):
	# Walk up to the entity holding these gloves
	var wearer: Entity = weapon_component.entity_holding_weapon

	# Find the wearer's current tile
	var wearer_tile: Vector2i = BoardGrid.world_to_tile(wearer.position)

	# Scan the 3x3 area centered on the wearer
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var tile: Vector2i = wearer_tile + Vector2i(dx, dy)

			# Skip tiles outside the grid
			if not BoardGrid.astar.region.has_point(tile):
				continue

			# Convert tile back to world position and look for an entity there
			var world_pos: Vector2 = BoardGrid.tile_to_world(tile)
			var entities: Array[Node] = get_tree().get_nodes_in_group(wearer.hostile_team)

			for entity in entities:
				if entity is Entity and entity.position.is_equal_approx(world_pos):
					if entity.health_component != null:
						entity.health_component.take_damage_flat(wearer, _calculate_damage(), false)
						print(entity.name + "Got RUMBLED!!!")
