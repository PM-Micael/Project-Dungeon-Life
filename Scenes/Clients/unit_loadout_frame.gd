extends Node2D
class_name UnitLoadoutFrame

@onready var unit_entity: Unit:
	set(value):
		unit_entity = value
		_on_unit_entity_change()

var unit_entity_container: EntityContainer
var weapon_entity_container: EntityContainer

@onready var buffs_h_box_container: HBoxContainer = $BuffFrame/Buffs/ScrollContainer/HBoxContainer
@onready var debuffs_h_box_container: HBoxContainer = $DebuffFrame/Debuffs/ScrollContainer/HBoxContainer

func _ready() -> void:
	var container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
	var unit_container_instance = container_scene.instantiate()
	unit_container_instance.name = "UnitContainer"
	unit_container_instance.position = Vector2(135, 170)
	unit_container_instance.scale = Vector2(4, 4)
	get_node("UnitPreview").add_child(unit_container_instance)
	
	var weapon_container_instance: EntityContainer = container_scene.instantiate()
	weapon_container_instance.name = "WeaponContainer"
	weapon_container_instance.position = Vector2(75, 120)
	weapon_container_instance.scale = Vector2(1, 1)
	get_node("WeaponPreviewFrame").add_child(weapon_container_instance)
	
	unit_entity_container = get_node("UnitPreview/UnitContainer")
	weapon_entity_container = get_node("WeaponPreviewFrame/WeaponContainer")

func fill_buffs():
	for child in buffs_h_box_container.get_children():
		child.queue_free()
	
	var effect_component: EffectComponent = unit_entity_container.entity.get_node("Components/EffectComponent") #unit_entity.effect_component.active_buffs
	var buffs: Array[Buff] = effect_component.active_buffs
	
	var loop_count: int = 0
	for buff in buffs:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.scale = Vector2(0.8, 0.8)
		sprite.position = Vector2(30 + (50*loop_count), 30)
		sprite.texture = load("res://Scripts/Effects/Buffs/"+buff.id+"/"+buff.id+".svg")
		buffs_h_box_container.add_child(sprite)
		loop_count += 1

func fill_debuffs():
	for child in debuffs_h_box_container.get_children():
		child.queue_free()
	
	var effect_component: EffectComponent = unit_entity_container.entity.get_node("Components/EffectComponent")
	var debuffs: Array[Debuff] = effect_component.active_debuffs
	
	var loop_count: int = 0
	for debuff in debuffs:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.scale = Vector2(0.8, 0.8)
		sprite.position = Vector2(30 + (50*loop_count), 30)
		sprite.texture = load("res://Scripts/Effects/Debuffs/"+debuff.id+"/"+debuff.id+".svg")
		sprite.texture = load("res://Scripts/Effects/Buffs/shield/shield.svg")
		debuffs_h_box_container.add_child(sprite)
		loop_count += 1

func _on_unit_entity_change():
	unit_entity_container.entity = unit_entity
	
	var weapon_slot_component = unit_entity.get_node("Components/WeaponSlotComponent")
	if weapon_slot_component != null:
		var weapon = weapon_slot_component.get_child(0)
		weapon_entity_container.entity = weapon if weapon != null else null

	# Update StatsFrame
	var health_component: HealthComponent = unit_entity.get_node("Components/HealthComponent")
	health_component.set_stats(unit_entity.get_total_health())
	var attack_component: AttackComponent = unit_entity.get_node("Components/AttackComponent")
	attack_component.set_stats_absolute(
		unit_entity.get_total_attack_damage(),
		unit_entity.attack_range,
		unit_entity.base_critical_percent_chance,
		unit_entity.base_critical_damage_multiplier)
	get_node("StatsFrame/Health/ValueLabel").text = str(health_component.current_health) + " / " + str(health_component.max_health)
	get_node("StatsFrame/Attack/ValueLabel").text = str(_get_display_attack_damage())
	
	# Connect signals for real-time updates (disconnect first to avoid duplicates)
	if health_component.damage_taken.is_connected(_on_selected_unit_health_changed):
		health_component.damage_taken.disconnect(_on_selected_unit_health_changed)
	health_component.damage_taken.connect(_on_selected_unit_health_changed)

	if attack_component.post_attack_target.is_connected(_on_selected_unit_attacked):
		attack_component.post_attack_target.disconnect(_on_selected_unit_attacked)
	attack_component.post_attack_target.connect(_on_selected_unit_attacked)
	
	fill_buffs()

func _on_selected_unit_health_changed(_attacker: Entity, _is_crit: bool):
	if not is_instance_valid(unit_entity):
		return
	get_node("StatsFrame/Health/ValueLabel").text = str(unit_entity.health_component.current_health) + " / " + str(unit_entity.health_component.max_health)

func _on_selected_unit_attacked(_targets: Array[Entity]):
	if not is_instance_valid(unit_entity):
		return
	get_node("StatsFrame/Attack/ValueLabel").text = str(_get_display_attack_damage())

func change_unit_weapon(new_weapon_entity: Entity):
	print("Changing unit weapon")
	DungeonData.change_unit_weapon(unit_entity, new_weapon_entity)

func _get_display_attack_damage() -> int:
	return unit_entity.get_node("Components/AttackComponent").get_total_attack_damage()
