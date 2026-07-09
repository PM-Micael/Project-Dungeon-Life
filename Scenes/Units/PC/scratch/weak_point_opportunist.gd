extends Blessing
class_name WeakPointOpportunist

func _init() -> void:
	id = "weak_point_opportunist"
	display_name = "Weak Point Opportunist"
	duration = 999
	stacks = 1

func apply(_target: Entity) -> void:
	stacks += 1
	# Only apply the attack speed buff once (on first stack)
	if buffs.size() == 0:
		var attack_speed_up = AttackSpeedUp.new()
		attack_speed_up.warer = warer
		attack_speed_up.owner = owner
		attack_speed_up.apply(warer)
		buffs.append(attack_speed_up)

func consume_stack() -> void:
	if stacks > 1:
		stacks -= 1
	elif stacks == 1:
		stacks -= 1
		# Remove the speed buff on last stack
		if buffs.size() > 0:
			var buff = buffs.pop_back()
			buff.remove(warer)
