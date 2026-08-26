extends Buff
class_name Shield

signal shield_broken

var shield_value: int:
	set(value):
		shield_value = value
		shield_progress_bar.value = shield_value

var flat_modifier = 0
var percent_modifier = 0.0
var shield_progress_bar: ProgressBar

func _init(flat: int, percent: float) -> void:
	id = "shield"
	display_name = "Shield"
	flat_modifier = flat
	percent_modifier = percent
	duration = 1000
	
	_set_sprite()

func _set_sprite():
	sprite = Sprite2D.new()
	sprite.texture = load("res://Assets/shield_buff_icon.png")
	sprite.modulate = "ffffff74"

func apply(_target: Entity):
	super.apply(_target)
	sprite.scale = warer.get_node("Sprite2D").scale - Vector2(0.27, 0.27)
	shield_progress_bar = warer.ui_component.shield_bar
	var value = (warer.health_component.max_health * percent_modifier) + flat_modifier
	shield_progress_bar.max_value = value
	shield_value = value
	warer.health_component.post_calculate_damage.connect(effect)

func effect(_unit: Unit, amount: int, _is_crit: bool):
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
		warer.effect_component.remove_effect(self, warer.effect_component.active_buffs)
		shield_broken.emit()

func remove():
	shield_progress_bar.value = 0
	pass
