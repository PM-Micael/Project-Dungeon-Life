extends Debuff
class_name Burning

# Burning damage starts low and then ramps up over time
var damage_per_tick: int = 5
var tick_timer: float = 0.0
var tick_interval: float = 1.0

func _init() -> void:
	id = "burning"
	display_name = "Burning"
	duration = 4
	stacks = 1

func apply(target: Entity) -> void:
	pass

func tick(target: Entity, delta: float) -> void:
	tick_timer += delta
	if tick_timer >= tick_interval:
		tick_timer = 0.0
		if is_instance_valid(target) and target.health_component != null:
			var attacker = owner if is_instance_valid(owner) else null
			target.health_component.take_damage_flat(attacker, damage_per_tick, false)
