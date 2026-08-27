extends Node2D
class_name AttackComponent

signal pre_attack_target
signal pre_attack_targets
signal post_attack_target
signal post_attack_targets

@export var base_attack_damage: int = 1
@export var base_attack_speed: float = 1.1
@export var attack_damage: int = 1
@export var attack_range: int = 100
@export var attack_speed: float = 1.1
@export var base_critical_percent_chance: int = 0
@export var base_critical_damage_multiplier: float = 1.0
@export var is_aoe: bool = false

# --- Shake settings ---
@export var shake_strength: float = 6.0   # pixels offset at peak
@export var shake_duration: float = 0.15  # total shake time in seconds

var weapon_added_multiplier: int = 0
var is_crit = false
var in_target_attack_range: bool = false

@onready var entity_parent: Unit = get_parent().get_parent()
@onready var timer: Timer = $Timer
@onready var attack_sound: AudioStreamPlayer = $AttackSound
@onready var attack_crit_sound: AudioStreamPlayer = $AttackCritSound
@onready var attack_sprite_scene: PackedScene = preload("res://Assets/Animations/Slash/slash.tscn")

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
	
	if entity_parent.targeting_component.target == null:
		return
	
	if timer.time_left <= 0.1:
		if is_aoe:
			entity_parent.attack_component.attack_targets(entity_parent.targeting_component.targets)
			if is_instance_valid(timer):
				timer.start()
			return
	
		var in_range: bool
		if entity_parent.movment_component != null:
			in_range = in_target_attack_range
		else:
			var dist = position.distance_to(entity_parent.targeting_component.target.position)
			in_range = dist <= attack_range * sqrt(2)
		if in_range:
			attack_target(entity_parent.targeting_component.target)
			if is_instance_valid(timer):
				timer.start()

func set_stats_absolute(
	set_attack_damage: int,
	set_attack_range: int,
	set_crit_chance: int,
	set_crit_damage
	):
	base_attack_damage = set_attack_damage
	attack_damage = set_attack_damage
	attack_range = set_attack_range
	base_critical_percent_chance = set_crit_chance
	base_critical_damage_multiplier = set_crit_damage

func attack_targets(targets: Array[Entity], bonus_damage: int = 0):
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
	
	if not is_instance_valid(self):
		return
	
	post_attack_targets.emit(targets if is_instance_valid(targets) else [],
	is_crit)

func attack_target(target: Entity, bonus_damage: int = 0):
	pre_attack_target.emit(target)
	is_crit = roll_crit()
	if is_crit:
		attack_crit_sound.play()
	else:
		attack_sound.play()

	_play_shake()
	#attack_animation.position = target.position
	#target.attack_component.attack_animation.scale = target.scale
	#target.attack_component.attack_animation.play("default")

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
	var wc: WeaponComponent
	var wsc: WeaponSlotComponent = get_parent().get_node_or_null("WeaponSlotComponent")
	var wc_damage: int = 0
	if wsc != null:
		wc = wsc.get_child(0).get_node("Components/WeaponComponent")
		wc_damage = wc.get_total_damage()

	if is_crit:
		return ((attack_damage*PlayerData.inner_sanctum.power) + wc_damage) * base_critical_damage_multiplier
	return ((attack_damage*PlayerData.inner_sanctum.power) + wc_damage)
