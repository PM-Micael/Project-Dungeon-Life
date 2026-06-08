extends Buff
class_name Shield

signal shield_broken

var shield_value = 0
var flat_modifier = 0
var percent_modifier = 0.0

func _init(flat: int, percent: float) -> void:
	flat_modifier = flat
	percent_modifier = percent

func apply(_target: Entity) -> void:
	shield_value = (warer.health_component.max_health * percent_modifier) + flat_modifier
	warer.health_component.post_calculate_damage.connect(effect)

func effect(_unit, amount, _is_crit):
	var hc = warer.health_component
	var incoming = (amount * hc.final_damage_taken_modifier)
	
	if shield_value >= incoming:
		shield_value -= incoming
		hc.final_damage_taken_amount = 0
	else:
		var overflow = incoming - shield_value
		hc.final_damage_taken_amount = overflow
		shield_value = 0
		hc.post_calculate_damage.disconnect(effect)
		warer.effect_component.remove_buff(self)
		shield_broken.emit()
		
