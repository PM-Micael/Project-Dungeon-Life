extends Entity

func _ready() -> void:
	super._ready()
	add_to_group("Team 2")
	hostile_team = "Team 1"
	name = "Golem"
