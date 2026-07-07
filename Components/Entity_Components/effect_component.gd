extends Node2D
class_name EffectComponent

signal buff_applied(target: Entity)
signal buff_extended(target: Entity)

signal debuff_applied(target: Entity)
signal debuff_extended(target: Entity)

@onready var parent_entity: Entity = get_parent().get_parent()

var active_buffs: Array[Buff] = []
var active_blessings: Array[Blessing] = []

var active_debuffs: Array[Debuff] = []
var active_afflictions: Array[Affliction] = []

func _physics_process(delta: float) -> void:
	_effect_countdown(delta, active_blessings)
	_effect_countdown(delta, active_afflictions)
	_effect_countdown(delta, active_buffs)
	_effect_countdown(delta, active_debuffs)
	
	for debuff in active_debuffs:
		debuff.tick(parent_entity, delta)
		if debuff.duration > 0:
			debuff.duration -= delta
			if debuff.duration <= 0:
				_remove_debuff(debuff)

func _effect_countdown(delta: float, effect_array: Array):
	for effect in effect_array:
		effect.tick(parent_entity, delta) # Check the tick. Will not always do the same
		if effect.duration > 0:
			effect.duration -= delta
		elif effect.duration <= 0:
			effect_array.erase(effect)

func add_blessing(blessing: Blessing, owner: Unit):
	blessing.warer = parent_entity
	blessing.owner = owner
	for existing in active_blessings:
		if blessing.stacks > 1:
			print("Stacking debuff")
		elif existing.id == blessing.id:
			existing.duration = blessing.duration
			debuff_extended.emit(parent_entity)
			return
	active_blessings.append(blessing)
	blessing.apply(parent_entity)

func add_affliction(affliction: Affliction, owner: Unit):
	affliction.warer = parent_entity
	affliction.owner = owner
	for existing in active_afflictions:
		if affliction.stacks > 1:
			print("Stacking debuff")
		elif existing.id == affliction.id:
			existing.duration = affliction.duration
			debuff_extended.emit(parent_entity)
			return
	active_afflictions.append(affliction)
	affliction.apply(parent_entity)

func add_buff(buff: Buff, owner: Unit):
	buff.warer = parent_entity
	buff.owner = owner
	for existing in active_buffs:
		if buff.stacks > 1:
			print("Stacking buff")
		elif existing.id == buff.id:
			existing.duration = buff.duration
			buff_extended.emit(parent_entity)
			return
	active_buffs.append(buff)
	buff.apply(parent_entity)
	buff_applied.emit(parent_entity)

func add_debuff(debuff: Debuff, owner: Unit):
	debuff.warer = parent_entity
	debuff.owner = owner
	for existing in active_debuffs:
		if debuff.stacks > 1:
			print("Stacking debuff")
		elif existing.id == debuff.id:
			existing.duration = debuff.duration
			debuff_extended.emit(parent_entity)
			return
	active_debuffs.append(debuff)
	debuff.apply(parent_entity)
	debuff_applied.emit(parent_entity)

func remove_buff(buff: Buff):
	buff.remove(parent_entity)
	active_buffs.erase(buff)

func _remove_debuff(debuff: Debuff):
	debuff.remove(parent_entity)
	active_debuffs.erase(debuff)
