extends Blessing
class_name MoltenDisaster

var shield_value_flat: int = 0
var shield_value_percent: float = 0.35
var charge_time: float = 5.0
var interupted = false
var shield: Shield
var channel_bar: ProgressBar
var is_channeling: bool:
	set(value):
		is_channeling = value
		warer.is_channeling = is_channeling

func _init() -> void:
	id = "molten_disaster"
	display_name = "Molten Disaster"
	duration = 6.0
	stacks = 1

func apply(_target: Entity) -> void:
	apply_shield()

func apply_shield():
	shield = Shield.new(shield_value_flat, shield_value_percent)
	shield.warer = owner
	shield.owner = owner
	shield.shield_broken.connect(_on_shield_broken)
	buffs.append(shield)
	shield.apply(owner)
	
	warer.start_channel(charge_time, "Magma Wave")
	warer.channel_complete.connect(_magma_wave)
	
	return
	
	channel_bar = warer.ui_component.channel_bar
	warer.ui_component.channel_title.text = "Magma Wave"
	channel_bar.max_value = charge_time
	channel_bar.value = charge_time
	is_channeling = true

func tick_down(_delta):
	return
	if channel_bar:
		channel_bar.value = (channel_bar.max_value - _delta)
		if _delta <= 0:
			channel_bar.value = 0
			warer.ui_component.channel_title.text = ""
			if interupted:
				return
			_magma_wave("Magma Wave")

func _magma_wave(title: String):
	if not title == "Magma Wave":
		return
	
	is_channeling = false
	var targets: Array[Node] = owner.get_parent().get_parent().get_node("FriendlyUnits").get_children()
	for target in targets:
		var bonus_damage = owner.attack_component.attack_damage * 2.5
		owner.attack_component.attack_target(target, bonus_damage)
	
	remove_early()

func _on_shield_broken():
	print("INTERUPTED MAGMA WAVE")
	warer.interrupt_channel("Magma Wave")
	interupted = true
	remove_early()
	warer.stun_unit(2.0)

func remove_early():
	warer.effect_component.remove_effect(shield, warer.effect_component.active_buffs)
	warer.effect_component.remove_effect(self, warer.effect_component.active_blessings)
