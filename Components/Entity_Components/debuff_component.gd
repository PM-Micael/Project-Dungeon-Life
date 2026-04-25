extends Node2D
class_name DebuffComponent

@onready var parent_entity: Entity = get_parent().get_parent()

var active_debuffs: Array[Debuff] = []

func add_debuff(debuff: Debuff):
	debuff.warer = parent_entity
	for existing in active_debuffs:
		if debuff.stacks > 1:
			print("Stacking debuff")
		elif existing.id == debuff.id:
			existing.duration = debuff.duration
			return
	active_debuffs.append(debuff)
	debuff.apply(parent_entity)

func _process(delta: float) -> void:
	for debuff in active_debuffs:
		debuff.tick(parent_entity, delta)
		if debuff.duration > 0:
			debuff.duration -= delta
			if debuff.duration <= 0:
				_remove_debuff(debuff)

func _remove_debuff(debuff: Debuff):
	debuff.remove(parent_entity)
	active_debuffs.erase(debuff)
