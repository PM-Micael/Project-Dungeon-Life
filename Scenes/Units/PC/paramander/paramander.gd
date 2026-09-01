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
	var facing: Vector2i = BoardGrid.get_facing_direction(self)

	var cone_tiles: Array[Vector2i] = BoardGrid.get_cone_tiles(my_tile, facing, CONE_DEPTH)

	var damage: int = int(attack_component.get_total_attack_damage() * CONE_DAMAGE_MULTIPLIER)
	var enemies: Array[Entity] = targeting_component.select_closest_target(hostile_team)

	for enemy in enemies:
		if enemy.health_component != null:
			var entity_tile: Vector2i = BoardGrid.world_to_tile(enemy.position)
			if entity_tile in cone_tiles:
				enemy.health_component.take_damage_flat(self, damage, false)
				
	VfxManager.spawn_cone_vfx(
		self,
		facing,
		ability_sprite_scene,
		CONE_DEPTH,
		TILE_SIZE,
		VFX_NATIVE_HALF_WIDTH,
		VFX_NATIVE_LENGTH)
