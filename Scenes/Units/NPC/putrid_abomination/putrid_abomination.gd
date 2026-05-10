extends Unit

@export_category("Stats")
@export var max_health: int = 100
@export var attack_damage: int = 5

func _init() -> void:
	id = "putrid_abomination"

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("putrid_abomination", "Putrid Abomination", "Team 2", "Team 1")
	add_construct_shield()

func add_construct_shield():
	var shield = Shield.new()
	shield.set_values(self, 20, 0.5)
	
	effect_component.add_buff(shield, self)
	
	print("Shield value = " + str(shield.shield_value))

func _set_stats():
	health_component.set_stats(max_health)
