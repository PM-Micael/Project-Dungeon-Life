extends Unit

const ATTACK_AOE_RADIUS: int = 2

var shield_cooldown: float = 7.0
var shield_recharge_timer: float = 0

func _init() -> void:
	id = "putrid_abomination"
	is_boss = true
	base_health = 800
	attack_damage = 20
	attack_range = 200
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2

	attack_sprite_scene = {
	"path": preload("res://Scenes/Animations/Attacks/putrid_burst.tscn"),
	"animation": "toxic",
	"scale": Vector2(1, 1),
	"native_size": 64.0,
	}

func _ready() -> void:
	super._ready()
	_info("putrid_abomination", "Putrid Abomination", "Team 2", "Team 1")
	attack_component.targeting_type = targeting_component.TYPE.ALL_IN_ATTACK_RANGE
	essence_value = [3, PlayerData.dungeon_layer_level*3]
	attack_component.post_attack_targets.connect(_burst_around_self)

func _physics_process(delta: float) -> void: 
	targeting_component.select_targets_in_attack_range("Team 1") ## Placeholder before attack component rework
	
	for effect in effect_component.active_blessings:
		if effect is FleshShield:
			return
	shield_recharge_timer -= delta
	if shield_recharge_timer <= 0:
		shield_recharge_timer = shield_cooldown
		_apply_flesh_shield()

## His attack hits everything in range at once, so it reads as one burst covering
## the block around him rather than a separate hit on each unit caught in it.
func _burst_around_self(targets: Array, _is_crit: bool):
	if targets.is_empty():
		return

	var my_tile: Vector2i = BoardGrid.world_to_tile(position)
	VfxManager.spawn_area_vfx(self, my_tile, ATTACK_AOE_RADIUS, attack_sprite_scene)

func _apply_flesh_shield():
	var flesh_shield = FleshShield.new()
	effect_component.add_effect(flesh_shield, self, effect_component.active_blessings)

func _set_stats() -> void:
	health_component.set_stats(get_total_health())
	attack_component.set_stats_absolute(get_total_attack_damage(), attack_range, base_critical_percent_chance, base_critical_damage_multiplier)
	attack_component.attack_speed = 1.6
