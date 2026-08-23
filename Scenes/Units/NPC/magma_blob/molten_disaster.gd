extends Blessing
class_name MoltenDisaster

var shield_value_flat: int = 10000
var shield_value_percent: float = 0.2
var charge_time: float = 5.0
var interupted = false
var shield_sprite: Sprite2D

func _init() -> void:
	id = "molten_disaster"
	display_name = "Molten Disaster"
	duration = 6.0
	stacks = 1

func apply(_target: Entity) -> void:
	apply_shield()

func apply_shield():
	var shield = Shield.new(shield_value_flat, shield_value_percent)
	shield.warer = owner
	shield.owner = owner
	shield.shield_broken.connect(_on_shield_broken)
	buffs.append(shield)
	shield.apply(owner)
	
	var timer = Timer.new()
	timer.wait_time = charge_time
	timer.one_shot = true
	owner.effect_component.add_child(timer)
	timer.timeout.connect(_magma_wave)
	timer.start()

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
