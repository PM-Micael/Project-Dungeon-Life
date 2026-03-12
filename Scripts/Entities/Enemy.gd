extends Entity

func _ready() -> void:
	super._ready()
	hostile_group_is = "friendly"
	name = "Dumdum"
	add_to_group("enemies")
