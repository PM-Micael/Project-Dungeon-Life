extends Unit

func _init() -> void:
	id = "small_salamander"
	
	base_health = 200
	attack_damage = 20
	attack_range = 250
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2
	
	attack_sprite_scene = {
	"path": preload("res://Assets/Animations/Splash/splash.tscn"),
	"animation": "magma",
	"scale": Vector2(6, 6),
	}

func _ready() -> void:
	super._ready()
	_info("small_salamander", "Small Small", "Team 2", "Team 1")
	essence_value = [1, PlayerData.dungeon_layer_level]
	attack_component.attack_type = attack_component.ATTACK_TYPE.PROJECTILE_SPLASH
	attack_component.is_aoe = true

func _set_stats() -> void:
	health_component.set_stats(get_total_health())
	attack_component.set_stats_absolute(
		get_total_attack_damage(),
		attack_range,
		base_critical_percent_chance,
		base_critical_damage_multiplier,
		attack_sprite_scene)
