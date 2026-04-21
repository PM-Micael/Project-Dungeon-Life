extends Entity

func _init() -> void:
	id = "unt_goblin"

func _ready() -> void:
	super._ready()
	add_to_group("Team 1")
	hostile_team = "Team 2"
	name = "goblin"
	display_name = "Goblin"
