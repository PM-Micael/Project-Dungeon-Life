extends Entity

func _ready() -> void:
	super._ready()
	name = "Dum dum"
	add_to_group("enemies")

func _choose_target():
	var entities = get_tree().get_nodes_in_group("friendly")
	
	var targets = []
	return
