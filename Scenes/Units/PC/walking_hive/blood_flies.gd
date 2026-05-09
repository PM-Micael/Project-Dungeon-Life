extends Affliction
class_name BloodFlies

var max_health_heal: float = 0.2

func _init() -> void:
	id = "blood_flies"
	display_name = "Blood Flies"
	duration = 6
	stacks = 1
	_construct_debuffs()
	_apply_debuffs()

func _construct_debuffs():
	var leech = Leech.new()
	leech.duration = duration
	leech.damage_to_health = 1.0
	affliction_debuffs.append(leech)

func _apply_debuffs():
	for debuff in affliction_debuffs:
		debuff.debuff_effect()

func apply(_target: Entity) -> void:
	warer.health_component.died.connect(blood_collector)
	warer.effect_component.debuff_applied.connect(_on_debuff_applied)

func _on_debuff_applied(target: Unit):
	if target.effect_component != null:
		for debuff in affliction_debuffs:
			debuff.debuff_effect()

func blood_collector(killer: Unit):
	print(self.display_name+" died")
	var board: GameBoard = killer.get_tree().get_node("TeamLineupMenu/Board")
	
	var lowest_health_unit: Unit
	var lowest_health: float
	
	for unit in board.friendly_units:
		var unit_health_percent =  unit.health_component.get_health_percent()
		
		if lowest_health == null:
			lowest_health_unit = unit
			lowest_health = unit.health_component.get_health_percent()
			return
		if unit_health_percent < lowest_health:
			lowest_health_unit = unit
			lowest_health = unit.health_component.get_health_percent()
	
	lowest_health_unit.health_component.current_health += (
		lowest_health_unit.health_component.max_health * max_health_heal
	)
	print(lowest_health_unit.display_name+" healed: "+str(max_health_heal))
	return
