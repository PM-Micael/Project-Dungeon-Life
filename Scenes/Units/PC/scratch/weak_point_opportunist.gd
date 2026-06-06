extends Blessing
class_name WeakPointOpportunist

func _init() -> void:
	id = "weak_point_opportunist"
	display_name = "Weak Point Opportunist"
	duration = -1
	stacks = 1

func apply(_target: Entity) -> void:
	# Each application adds one AttackSpeedUp buff to the warer (Scratch himself)
	var speed_buff = AttackSpeedUp.new()
	speed_buff.warer = warer
	speed_buff.owner = owner
	speed_buff.apply(warer)
	buffs.append(speed_buff)
	print("Weak Point Opportunist stack applied. Total stacks: " + str(buffs.size()))
 
func consume_stack() -> void:
	if buffs.size() > 0:
		var buff = buffs.pop_back()
		buff.remove(warer)
		print("Feral Instinct stack consumed. Remaining: " + str(buffs.size()))
