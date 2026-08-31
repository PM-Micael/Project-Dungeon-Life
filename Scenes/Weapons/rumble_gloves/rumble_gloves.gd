extends Entity

const SLAM_RADIUS: int = 1

var ability_sprite_scene = {
	"path": preload("res://Scenes/Animations/Skills/ground_slam.tscn"),
	"animation": "dust",
	"scale": Vector2(1, 1),
	"native_size": 64.0,
	}

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

## Slams the ground, hitting everything in the block of tiles around the wearer.
func _weapon_skill(_targets: Array[Entity]):
	weapon_component.weapon_skill_sound.play()

	# Walk up to the entity holding these gloves
	var wearer: Entity = weapon_component.entity_holding_weapon
	var wearer_tile: Vector2i = BoardGrid.world_to_tile(wearer.position)
	var tiles: Array[Vector2i] = BoardGrid.get_tiles_around(wearer_tile, SLAM_RADIUS)

	for entity in get_tree().get_nodes_in_group(wearer.hostile_team):
		if entity is Entity and entity.health_component != null:
			if BoardGrid.world_to_tile(entity.position) in tiles:
				entity.health_component.take_damage_flat(wearer, _calculate_damage(), false)

	VfxManager.spawn_area_vfx(wearer, wearer_tile, SLAM_RADIUS, ability_sprite_scene)
