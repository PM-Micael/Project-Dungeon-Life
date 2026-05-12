extends Entity

@export var basic_attack_damage: int = 10

var heal_reduction_modifier: float = 0.4
var weaken_modifier: float = 0.25

func _init() -> void:
	id = "cursed_lantern"

func _ready() -> void:
	name = "cursed_lantern"
	display_name = "Cursed Lantern"
	weapon_component.set_stats_absolute(basic_attack_damage)
	weapon_component.use_weapon_skill.connect(_weapon_skill)

func _weapon_skill(targets: Array[Entity]):
	print("Cursed flame")
	var wearer: Entity = weapon_component.entity_holding_weapon

	if targets.is_empty():
		return

	var target: Entity = targets[0]

	if target.effect_component == null:
		return

	var heal_reduction = HealReduction.new()
	heal_reduction.reduced_healing = heal_reduction_modifier
	heal_reduction.duration = 5

	var weaken = Weaken.new()
	weaken.damage_modifier = weaken_modifier
	weaken.duration = 5

	target.effect_component.add_debuff(heal_reduction, wearer)
	target.effect_component.add_debuff(weaken, wearer)
