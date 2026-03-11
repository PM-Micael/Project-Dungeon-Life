extends Entity

var enemy_target

func _ready() -> void:
	super._ready()
	name = "Friend"
	add_to_group("friendly")

func entity_action():
	_choose_target()

func _choose_target():
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	if enemies.size() <= 0:
		enemy_target = null
		return

	# Start with the first enemy
	var closest_entity = enemies[0]
	var closest_dist = global_position.distance_squared_to(closest_entity.global_position)

	for e in enemies:
		if e == self:
			continue  # skip self, just in case
		# calculate squared distance
		var dist = global_position.distance_squared_to(e.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_entity = e

	enemy_target = closest_entity
	print("Closest enemy:", enemy_target.name)
