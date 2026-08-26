extends Node2D
class_name EffectComponent

signal effect_applied(target: Entity, effect: Effect)
signal effect_expired(target: Entity, effect: Effect)

@onready var parent_entity: Unit = get_parent().get_parent()

var active_buffs: Array[Buff] = []
var active_blessings: Array[Blessing] = []

var active_debuffs: Array[Debuff] = []
var active_afflictions: Array[Affliction] = []

func _physics_process(delta: float) -> void:
	_effect_countdown(delta, active_blessings)
	_effect_countdown(delta, active_afflictions)
	_effect_countdown(delta, active_buffs)
	_effect_countdown(delta, active_debuffs)

func _effect_countdown(delta: float, effect_array: Array):
	for effect in effect_array:
		if effect.duration > 0:
			effect.duration -= delta
		elif effect.duration <= 0:
			remove_effect(effect, effect_array)

func add_effect(effect: Effect, owner: Unit, effect_array: Array):
	effect.warer = parent_entity
	effect.owner = owner
	for e in effect_array:
		if effect.stacks > 1:
			print("Stacking effect not yet implimented")
		elif e.id == effect.id:
			e.duration = effect.duration
			effect_applied.emit(parent_entity, effect)
			return
	effect_array.append(effect)
	effect.apply(parent_entity)
	effect_applied.emit(parent_entity, effect)

func remove_effect(effect: Effect, effect_array: Array):
	effect_array.erase(effect)
	effect.remove()
	effect_expired.emit(parent_entity, effect)
