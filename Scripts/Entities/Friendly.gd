extends Entity

var enemy_target

func _ready() -> void:
	super._ready()
	hostile_group_is = "enemies"
	name = "Tom"
	add_to_group("friendly")
