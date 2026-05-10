extends Effect
class_name Blessing

var blessing_buffs: Array[Debuff]

func _set_debuffs(set_buffs: Array[Debuff]):
	blessing_buffs = set_buffs
