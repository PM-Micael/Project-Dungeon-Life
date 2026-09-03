extends Unit

const ATTACK_AOE_RADIUS: int = 2

var skill_cooldown: float = 4.0

func _init() -> void:
	id = "magma_blob"
	is_boss = true
	base_health = 1000
	attack_damage = 10
	attack_range = 200
	base_defense = 0
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2

	attack_sprite_scene = {
	"path": preload("res://Scenes/Animations/Attacks/magma_wave_small.tscn"),
	"animation": "magma",
	"scale": Vector2(1, 1),
	"native_size": 64.0,
	}

func _ready() -> void:
	super._ready()
	_info("magma_blob", "Magma Blob", "Team 2", "Team 1")
	attack_component.targeting_type = targeting_component.TYPE.ALL_IN_ATTACK_RANGE
	attack_component.attack_type = attack_component.ATTACK_TYPE.MELEE_AOE
	essence_value = [3, PlayerData.dungeon_layer_level*3]
	#attack_component.post_attack_targets.connect(_wave_around_self)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_stunned:
		return

	for effect in effect_component.active_blessings:
		if effect is MoltenDisaster:
			return
	
	skill_cooldown -= delta
	if skill_cooldown <= 0:
		var effect = MoltenDisaster.new()
		effect_component.add_effect(
			effect,
			self,
			effect_component.active_blessings
			)
		skill_cooldown = 4.0

## A shrunk-down Magma Wave washing over the tiles around him — his attack hits
## them all at once, so it reads as one wave rather than a hit per unit.
func _wave_around_self(targets: Array, _is_crit: bool):
	if targets.is_empty():
		return

	var my_tile: Vector2i = BoardGrid.world_to_tile(position)
	VfxManager.spawn_area_vfx(self, my_tile, ATTACK_AOE_RADIUS, attack_sprite_scene)

func _set_stats() -> void:
	health_component.set_stats(get_total_health(), base_defense)
	attack_component.set_stats_absolute(
		get_total_attack_damage(),
		attack_range,
		base_critical_percent_chance,
		base_critical_damage_multiplier,
		attack_sprite_scene
		)
	attack_component.attack_speed = 1.6
