extends Blessing
class_name FleshShield

func _init() -> void:
	id = "flesh_shield"
	display_name = "Flesh Shield"
	duration = 6
	stacks = 1
	set_buffs()

func set_buffs():
	var shield = Shield.new(20, 0.5)
	shield.duration = 20
	buffs.append(shield)

func apply(_target: Entity) -> void:
	for buff in buffs:
		buff.warer = owner
		buff.owner = owner
		buff.apply(owner)
