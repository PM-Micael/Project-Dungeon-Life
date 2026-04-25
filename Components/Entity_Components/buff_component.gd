extends Node2D
class_name BuffComponent

@onready var parent_entity: Entity = get_parent().get_parent()

var active_buffs: Array[Buff] = []

func add_buff(buff: Buff, owner: Unit):
	buff.warer = parent_entity
	buff.owner = owner
	for existing in active_buffs:
		if buff.stacks > 1:
			print("Stacking buff")
		elif existing.id == buff.id:
			existing.duration = buff.duration
			return
	active_buffs.append(buff)
	buff.apply(parent_entity)

func _process(delta: float) -> void:
	for buff in active_buffs:
		buff.tick(parent_entity, delta)
		if buff.duration > 0:
			buff.duration -= delta
			if buff.duration <= 0:
				_remove_buff(buff)

func _remove_buff(buff: Buff):
	buff.remove(parent_entity)
	active_buffs.erase(buff)
