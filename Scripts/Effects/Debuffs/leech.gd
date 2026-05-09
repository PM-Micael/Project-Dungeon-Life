extends Debuff
class_name Leech

var damage_to_health: float

func _init() -> void:
	id = "leech"
	display_name = "Leech"
	set_properties()

func set_properties():
	duration = 5
	stacks = 1

func debuff_effect():
	return
