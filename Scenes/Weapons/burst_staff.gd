extends Entity

func _init() -> void:
	id = "item_weapon_burst_staff"

func _ready() -> void:
	name = "burst_staff"
	display_name = "Burst Staff"
	weapon_component.use_weapon_skill.connect(_weapon_skill)

func _weapon_skill(targets: Array[Entity]):
	print("Burst Staff weapon skill")
	
