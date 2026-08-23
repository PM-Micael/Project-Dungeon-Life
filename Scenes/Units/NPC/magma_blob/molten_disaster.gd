extends Blessing
class_name MoltenDisaster

var shield_value_flat: int = 10000
var shield_value_percent: float = 0.2
var charge_time: float = 5.0
var interupted = false
var shield: Shield
var channel_bar: ProgressBar

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
	
	channel_bar = warer.ui_component.channel_bar
	channel_bar.max_value = charge_time
	channel_bar.value = charge_time
	
	#var timer = Timer.new()
	#timer.wait_time = charge_time
	#timer.one_shot = true
	#owner.effect_component.add_child(timer)
	#timer.timeout.connect(_magma_wave)
	#timer.start()

func tick_down(_delta):
	if channel_bar:
		channel_bar.value = _delta
		if _delta <= 0:
			_magma_wave()

func _magma_wave():
	print("MAGMA WAVE!!!_______________________________________________________")
	var targets: Array[Node] = owner.get_parent().get_parent().get_node("EnemyUnits").get_children()
	for target in targets:
		var bonus_damage = owner.attack_component.attack_damage * 3
		owner.attack_component.attack_target(target, bonus_damage)
	
	remove()

func _on_shield_broken():
	print("INTERUPTED MAGMA WAVE")
	interupted = true
	duration = 0
	remove()

func remove():
	warer.effect_component.remove_effect(self, warer.effect_component.active_blessings)
