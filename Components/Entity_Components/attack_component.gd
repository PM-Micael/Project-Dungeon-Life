extends Node2D
class_name AttackComponent

signal pre_attack_target
signal pre_attack_targets
signal post_attack_target
signal post_attack_targets

const ATTACK_TYPE = {
	MELEE = 0,
	MELEE_LONG = 1,
	PROJECTILE = 2,
	PROJECTILE_SPLASH = 3
}
var attack_type: int = 0 

var targeting_type: int = 0

@export var base_attack_damage: int = 1
@export var base_attack_speed: float = 1.1
@export var attack_damage: int = 1
@export var attack_range: int = 100
@export var attack_speed: float = 1.1
@export var base_critical_percent_chance: int = 0
@export var base_critical_damage_multiplier: float = 1.0
@export var is_aoe: bool = false ## TEMP

# --- Shake settings ---
@export var shake_strength: float = 6.0   # pixels offset at peak
@export var shake_duration: float = 0.15  # total shake time in seconds
var attack_sprite_scene: Dictionary = {}

var weapon_added_multiplier: int = 0
var is_crit = false
var in_target_attack_range: bool = false

@onready var entity_parent: Unit = get_parent().get_parent()
@onready var timer: Timer = $Timer
@onready var attack_sound: AudioStreamPlayer = $AttackSound
@onready var attack_crit_sound: AudioStreamPlayer = $AttackCritSound

func _ready() -> void:
	timer.wait_time = attack_speed
	attack_sound.volume_db = AudioManager.get_gain(["volume_sfx"])
	attack_crit_sound.volume_db = AudioManager.get_gain(["volume_sfx"])
	timer.start()

func _physics_process(_delta: float) -> void:
	if entity_parent.is_stunned:
		return
	
	if entity_parent.is_channeling:
		return
	
	if entity_parent.targeting_component == null:
		return
	
	_attempt_attack()

func set_stats_absolute(
	set_attack_damage: int,
	set_attack_range: int,
	set_crit_chance: int,
	set_crit_damage: float,
	set_attack_sprite_scene: Dictionary = {}
	):
	base_attack_damage = set_attack_damage
	attack_damage = set_attack_damage
	attack_range = set_attack_range
	base_critical_percent_chance = set_crit_chance
	base_critical_damage_multiplier = set_crit_damage
	attack_sprite_scene = set_attack_sprite_scene

func _attempt_attack():
	if timer.time_left <= 0.1:
		var tc = entity_parent.targeting_component
		var targets: Array[Entity]
		match targeting_type:
			tc.TYPE.CLOSEST:
				targets = tc.select_closest_target(entity_parent.hostile_team)
			tc.TYPE.ALL_CLOSE_3x3:
				pass
			
		attack_targets(targets)
		
		if is_instance_valid(timer):
			timer.start()

func attack_targets(
	targets: Array[Entity],
	bonus_damage: int = 0,
	):
	pre_attack_targets.emit(targets)
	is_crit = roll_crit()
	if is_crit:
		attack_crit_sound.play()
	else:
		attack_sound.play()

	_play_shake()
	
	for target in targets:
		if not is_instance_valid(target):
			continue
		var target_health_component: HealthComponent = target.health_component
		if target_health_component != null:
			target_health_component.take_damage_flat(
				entity_parent,
				get_total_attack_damage(is_crit) + bonus_damage, is_crit)
	
		match attack_type:
			ATTACK_TYPE.PROJECTILE_SPLASH:
				var target_pos = BoardGrid.world_to_tile(target.position)
				var tiles: Array[Vector2i] = BoardGrid.get_tiles_surrounding_target(target_pos)
				var enemy_team_node: String
				if entity_parent.hostile_team == "Team 1":
					enemy_team_node = "FriendlyUnits"
				else:
					enemy_team_node = "EnemyUnits"
				var board_targets: Array = entity_parent.get_parent().get_parent().get_node(enemy_team_node).get_children()
				
				for t in board_targets:
					if t == targets[0]:
						continue
			
					if t.hostile_team == entity_parent.hostile_team:
						continue
			
					var unit_tile = BoardGrid.world_to_tile(t.position)
			
					if unit_tile in tiles:
						t.health_component.take_damage_flat(
							entity_parent,
							get_total_attack_damage(),
							false,
							false)
		
		if not is_instance_valid(target):
			targets.erase(target)
	
	if not is_instance_valid(self):
		return
	
	post_attack_targets.emit(targets, is_crit)

func attack_target(target: Entity, bonus_damage: int = 0,):
	pre_attack_target.emit(target)
	is_crit = roll_crit()
	if is_crit:
		attack_crit_sound.play()
	else:
		attack_sound.play()

	_play_shake()

	var target_health_component: HealthComponent = target.health_component
	if target_health_component != null:
		target_health_component.take_damage_flat(
			entity_parent,
			get_total_attack_damage(is_crit) + bonus_damage, is_crit)

	if not is_instance_valid(self):
		return
	var targets: Array[Entity] = [target]
	post_attack_target.emit(targets if is_instance_valid(target) else [],
	is_crit)

func attack_target_with_splash(targets: Array[Unit], bonus_damage: int = 0):
	pre_attack_targets.emit(targets)
	is_crit = roll_crit()
	if is_crit:
		attack_crit_sound.play()
	else:
		attack_sound.play()
	_play_shake()

	for t in targets:
		if not is_instance_valid(t):
			continue
		var target_health_component: HealthComponent = t.health_component
		if target_health_component != null:
			target_health_component.take_damage_flat(
				entity_parent,
				get_total_attack_damage(is_crit) + bonus_damage, is_crit)
				
	if not is_instance_valid(self):
		return
		
	post_attack_targets.emit(targets if is_instance_valid(targets) else [],
	is_crit)

# Shakes the entity's Sprite2D by tweening its position offset.
func _play_shake() -> void:
	var sprite: Sprite2D = entity_parent.get_node_or_null("Sprite2D")
	if sprite == null:
		return

	var origin: Vector2 = sprite.position
	var step: float = shake_duration / 4.0

	var tween: Tween = create_tween()
	tween.tween_property(sprite, "position", origin + Vector2(shake_strength, 0), step)
	tween.tween_property(sprite, "position", origin + Vector2(-shake_strength, 0), step)
	tween.tween_property(sprite, "position", origin + Vector2(shake_strength * 0.5, 0), step)
	tween.tween_property(sprite, "position", origin, step)

func roll_crit() -> bool:
	var crit_roll = randi_range(0, 100)
	if crit_roll <= base_critical_percent_chance:
		return true
	return false

func get_total_attack_damage(is_crit: bool = false) -> int:
	var wsc: WeaponSlotComponent = get_parent().get_node_or_null("WeaponSlotComponent")
	var wc_damage: int = 0
	if wsc != null and wsc.weapon != null:
		var wc: WeaponComponent = wsc.weapon.get_node_or_null("Components/WeaponComponent")
		if wc != null:
			wc_damage = wc.get_total_damage()

	if is_crit:
		return ((attack_damage*PlayerData.inner_sanctum.power) + wc_damage) * base_critical_damage_multiplier
	return ((attack_damage*PlayerData.inner_sanctum.power) + wc_damage)
