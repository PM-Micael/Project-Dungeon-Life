extends Entity

@export var basic_attack_damage: int = 2

func _init() -> void:
	id = "burst_staff"

func _ready() -> void:
	name = "burst_staff"
	display_name = "Burst Staff"
	weapon_component.set_stats_absolute(basic_attack_damage)
	weapon_component.use_weapon_skill.connect(_weapon_skill)

func _weapon_skill(targets: Array[Entity]):
	print("Burst Staff weapon skill")
	
