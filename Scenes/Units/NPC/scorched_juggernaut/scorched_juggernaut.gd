extends Unit

const STRIKE_DEPTH: int = 2

func _init() -> void:
	id = "scorcheed_juggernaut"
	passive_description = "Slams the ground, hitting everything two tiles ahead of him."

	base_health = 200
	base_defense = 30
	attack_damage = 10
	attack_range = 100
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2

	attack_sprite_scene = {
	"path": preload("res://Scenes/Animations/Attacks/two_cone_strike.tscn"),
	"animation": "magma",
	"scale": Vector2(2.5, 2.5),
	"rotation_offset": PI,  # the slam art points -X at rest
	}

func _ready() -> void:
	super._ready()
	_info("scorcheed_juggernaut", "Scorcheed Suggernaut", "Team 2", "Team 1")
	essence_value = [1, PlayerData.dungeon_layer_level]
	attack_component.post_attack_targets.connect(_strike_tiles_ahead)

func _set_stats() -> void:
	health_component.set_stats(
		get_total_health(),
		base_defense)
	attack_component.set_stats_absolute(
		get_total_attack_damage(),
		attack_range,
		base_critical_percent_chance,
		base_critical_damage_multiplier)

## Every attack also hits the tiles straight ahead of him, in whichever of the 8
## directions he is facing. `targets` already took the base attack, so they are
## skipped here instead of being hit twice.
func _strike_tiles_ahead(targets: Array, _is_crit: bool):
	var my_tile: Vector2i = BoardGrid.world_to_tile(position)
	var facing: Vector2i = BoardGrid.get_facing_direction(self)
	var tiles: Array[Vector2i] = BoardGrid.get_tiles_ahead(my_tile, facing, STRIKE_DEPTH)

	var damage: int = attack_component.get_total_attack_damage()

	for entity in get_tree().get_nodes_in_group(hostile_team):
		if entity in targets:
			continue
		if entity is Entity and entity.health_component != null:
			if BoardGrid.world_to_tile(entity.position) in tiles:
				entity.health_component.take_damage_flat(self, damage, false, false)

	VfxManager.spawn_tile_vfx(self, tiles, facing, attack_sprite_scene)
