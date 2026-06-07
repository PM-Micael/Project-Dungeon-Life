extends Entity

var crit_charges: int = 0
var bonus_crit_multiplier: float = 0.5

var _original_crit_chance: int = 0
var _original_crit_multiplier: float = 0.0

func _init() -> void:
	id = "heat_seeker"

func _ready() -> void:
	name = "heat_seeker"
	display_name = "Heat Seeker"
	weapon_component.use_weapon_skill.connect(_weapon_skill)

func _weapon_skill(_targets: Array[Entity]):
	print("Absorb Heat")
