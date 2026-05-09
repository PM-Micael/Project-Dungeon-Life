extends Effect
class_name Affliction

var affliction_debuffs: Array[Debuff]

func _set_debuffs(set_debuffs: Array[Debuff]):
	affliction_debuffs = set_debuffs
