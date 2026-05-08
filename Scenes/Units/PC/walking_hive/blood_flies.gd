extends Debuff
class_name BloodFlies

var max_health_heal: float = 0.2

func _init() -> void:
	id = "blood_flies"
	display_name = "Blood Flies"
	duration = 6
	stacks = 1

func apply(_target: Entity) -> void:
	warer.health_component.died.connect(_on_warer_died)

func _on_warer_died(killer: Unit):
	var board: GameBoard = killer.get_tree().get_node("TeamLineupMenu/Board")
	
	var lowest_health_unit: Unit
	var lowest_health
	
	for unit in board.friendly_units:
		if lowest_health == null:
			lowest_health = unit.health_component.current_health
			return
		
	print("trigger blood heal")
	return
