extends Entity
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _init() -> void:
	id = "rumble_gloves"

func _ready() -> void:
	name = "rumble_gloves"
	display_name = "Rumble Gloves"
	weapon_component.weapon_energy_gained_on_damage_taken = 3
	weapon_component.use_weapon_skill.connect(_weapon_skill)

func _calculate_damage() -> int:
	var wearer: Entity = weapon_component.entity_holding_weapon
	var is_crit: bool = false
	if weapon_component.ability_can_crit:
		is_crit = wearer.attack_component.roll_crit()
	
	var total_damage = wearer.attack_component.get_total_attack_damage(is_crit)
	
	return total_damage

func _weapon_skill(_targets: Array[Entity]):
	audio_stream_player.play()
	
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
