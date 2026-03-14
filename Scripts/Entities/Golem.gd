extends Entity

func _ready() -> void:
	super._ready()
	hostile_team = "Team 1"
	name = "Golem"
	add_to_group("Team 2")
