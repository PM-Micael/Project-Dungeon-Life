extends Blessing
class_name WeakPointOpportunist

func _init() -> void:
	id = "weak_point_opportunist"
	display_name = "Weak Point Opportunist"
	duration = -1
	stacks = 1

func apply(_target: Entity) -> void:
	stacks += 1
	# Only apply the attack speed buff once (on first stack)
	if buffs.size() == 0:
		var speed_buff = AttackSpeedUp.new()
		speed_buff.warer = warer
		speed_buff.owner = owner
		speed_buff.apply(warer)
		buffs.append(speed_buff)

func consume_stack() -> void:
	if stacks > 1:
		stacks -= 1
	elif stacks == 1:
		stacks -= 1
		# Remove the speed buff on last stack
		if buffs.size() > 0:
			var buff = buffs.pop_back()
			buff.remove(warer)
