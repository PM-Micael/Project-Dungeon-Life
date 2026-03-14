extends Entity

func _ready() -> void:
	super._ready()
	add_to_group("Team 1")
	hostile_team = "Team 2"
	name = "Goblin"
