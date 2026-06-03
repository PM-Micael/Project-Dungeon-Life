extends Entity

var crit_charges: int = 0
var bonus_crit_multiplier: float = 0.5

var _original_crit_chance: int = 0
var _original_crit_multiplier: float = 0.0

func _init() -> void:
	id = "splinter"

func _ready() -> void:
	name = "splinter"
	display_name = "Splinter"
	weapon_component.use_weapon_skill.connect(_weapon_skill)

func _weapon_skill(_targets: Array[Entity]):
	print("Tripple shot Activated")
	if crit_charges > 0:
		return
	
	var wearer: Entity = weapon_component.entity_holding_weapon
	
	# Snapshot the wearer's current stats before overwriting
	_original_crit_chance = wearer.attack_component.base_critical_percent_chance
	_original_crit_multiplier = wearer.attack_component.base_critical_damage_multiplier
	
	crit_charges = 3
	wearer.attack_component.base_critical_percent_chance = 100
	wearer.attack_component.base_critical_damage_multiplier += bonus_crit_multiplier * weapon_component.star_level
	
	wearer.attack_component.post_attack_target.connect(_on_attack_fired)

func _on_attack_fired(_targets: Array[Entity], _is_crit: bool):
	print("Shot "+str(crit_charges))
	crit_charges -= 1
	if crit_charges <= 0:
		_remove_buff()

func _remove_buff():
	var wearer: Entity = weapon_component.entity_holding_weapon
	
	wearer.attack_component.base_critical_percent_chance = _original_crit_chance
	wearer.attack_component.base_critical_damage_multiplier = _original_crit_multiplier
	
	if wearer.attack_component.post_attack_target.is_connected(_on_attack_fired):
		wearer.attack_component.post_attack_target.disconnect(_on_attack_fired)
	
	crit_charges = 0
