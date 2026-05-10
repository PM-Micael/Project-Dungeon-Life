extends Buff
class_name Shield

var shield_value = 0
var flat_modifier = 0
var percent_modifier = 1.0

func set_values(_warer, flat: int, percent: float):
	flat_modifier = flat
	percent_modifier = percent
	
	shield_value = (_warer.health_component.max_health * percent_modifier) + flat_modifier

func apply(_target: Entity) -> void:
	warer.health_component.post_calculate_damage.connect(effect)

func effect(_unit, amount, _is_crit):
	var hc = warer.health_component
	var incoming = (amount * hc.final_damage_taken_modifier)
	
	if shield_value >= incoming:
		shield_value -= incoming
		hc.final_damage_taken_amount = 0
		print("Shielded against ["+str(int(incoming))+"] damage")
	else:
		var overflow = incoming - shield_value
		hc.final_damage_taken_amount = overflow
		shield_value = 0
		print("Shield broke")
		hc.post_calculate_damage.disconnect(effect)
		warer.effect_component.remove_buff(self)
		
