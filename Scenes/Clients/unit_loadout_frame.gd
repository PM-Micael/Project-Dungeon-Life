## Read-only view of a single Entity. Binds to that entity's components when assigned
## and repaints from their signals. It never writes to the entity.
extends Node2D
class_name UnitLoadoutFrame

const BUFF_ICON_DIR: String = "res://Scripts/Effects/Buffs/"
const DEBUFF_ICON_DIR: String = "res://Scripts/Effects/Debuffs/"
const ICON_SIZE: Vector2 = Vector2(48, 48)

@onready var unit_container: EntityContainer = $UnitPreview/UnitContainer
@onready var weapon_container: EntityContainer = $WeaponPreviewFrame/WeaponContainer
@onready var health_label: Label = $StatsFrame/Health/ValueLabel
@onready var attack_label: Label = $StatsFrame/Attack/ValueLabel
@onready var buffs_box: HBoxContainer = $BuffFrame/Buffs/ScrollContainer/HBoxContainer
@onready var debuffs_box: HBoxContainer = $DebuffFrame/Debuffs/ScrollContainer/HBoxContainer

## Assign null to clear the panel. Setting this rebinds every subscription.
var entity: Entity = null:
	set(value):
		if entity == value:
			return
		_unbind()
		entity = value
		_bind()
		_refresh()

var _bound: Array = [] # of [Signal, Callable]

func _ready() -> void:
	_refresh()

# ── Binding ───────────────────────────────────────────────────────────────────

## The single source of truth for what this view listens to.
func _subscriptions(e: Entity) -> Array:
	var subs: Array = []
	if e.health_component != null:
		subs.append([e.health_component.health_changed, _on_health_changed])
		subs.append([e.health_component.died, _on_died])
	if e.effect_component != null:
		# Effects also mutate AttackComponent.attack_damage (AttackUp/AttackDown),
		# so these drive the attack label as well as the icon lists.
		subs.append([e.effect_component.effect_applied, _on_effects_changed])
		subs.append([e.effect_component.effect_expired, _on_effects_changed])
	if e.weapon_slot_component != null:
		subs.append([e.weapon_slot_component.weapon_changed, _on_weapon_changed])
	return subs

func _bind() -> void:
	if not is_instance_valid(entity):
		return
	for pair in _subscriptions(entity):
		pair[0].connect(pair[1])
		_bound.append(pair)

func _unbind() -> void:
	for pair in _bound:
		var sig: Signal = pair[0]
		if is_instance_valid(sig.get_object()) and sig.is_connected(pair[1]):
			sig.disconnect(pair[1])
	_bound.clear()

# ── Handlers ──────────────────────────────────────────────────────────────────

func _on_health_changed(current: int, maximum: int) -> void:
	health_label.text = "%d / %d" % [current, maximum]

func _on_died(_unit: Unit) -> void:
	entity = null

func _on_effects_changed(_target: Entity, _effect: Effect) -> void:
	attack_label.text = _attack_text()
	_fill_effects()

func _on_weapon_changed(new_weapon: Entity) -> void:
	weapon_container.entity = new_weapon
	attack_label.text = _attack_text()

# ── Painting ──────────────────────────────────────────────────────────────────

func _refresh() -> void:
	if not is_node_ready():
		return

	var valid: bool = is_instance_valid(entity)
	unit_container.entity = entity if valid else null
	weapon_container.entity = entity.weapon_slot_component.weapon if valid and entity.weapon_slot_component != null else null
	health_label.text = _health_text()
	attack_label.text = _attack_text()
	_fill_effects()

func _health_text() -> String:
	if not is_instance_valid(entity) or entity.health_component == null:
		return ""
	return "%d / %d" % [entity.health_component.current_health, entity.health_component.max_health]

func _attack_text() -> String:
	if not is_instance_valid(entity) or entity.attack_component == null:
		return ""
	return str(entity.attack_component.get_total_attack_damage())

func _fill_effects() -> void:
	var effect_component: EffectComponent = entity.effect_component if is_instance_valid(entity) else null
	if effect_component == null:
		_populate(buffs_box, [], BUFF_ICON_DIR)
		_populate(debuffs_box, [], DEBUFF_ICON_DIR)
		return

	# Blessings and afflictions have no icon of their own - they are drawn as the
	# buffs/debuffs they carry.
	var buffs: Array = []
	buffs.append_array(effect_component.active_buffs)
	for blessing: Blessing in effect_component.active_blessings:
		buffs.append_array(blessing.buffs)

	var debuffs: Array = []
	debuffs.append_array(effect_component.active_debuffs)
	for affliction: Affliction in effect_component.active_afflictions:
		debuffs.append_array(affliction.debuffs)

	_populate(buffs_box, buffs, BUFF_ICON_DIR)
	_populate(debuffs_box, debuffs, DEBUFF_ICON_DIR)

func _populate(box: HBoxContainer, effects: Array, icon_dir: String) -> void:
	for child in box.get_children():
		child.queue_free()

	for effect: Effect in effects:
		var icon_path: String = icon_dir + effect.id + "/" + effect.id + ".svg"
		if not ResourceLoader.exists(icon_path):
			continue

		# TextureRect, not Sprite2D: an HBoxContainer only lays out Control children.
		var icon := TextureRect.new()
		icon.texture = load(icon_path)
		icon.custom_minimum_size = ICON_SIZE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.tooltip_text = effect.display_name
		box.add_child(icon)
