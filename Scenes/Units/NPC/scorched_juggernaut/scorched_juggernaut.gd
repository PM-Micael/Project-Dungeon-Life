extends Unit

func _init() -> void:
	id = "scorcheed_juggernaut"
	
	base_health = 200
	base_defense = 30
	attack_damage = 10
	attack_range = 100
	base_critical_percent_chance = 0
	base_critical_damage_multiplier = 1.2

func _ready() -> void:
	super._ready()
	_set_stats()
	_info("scorcheed_juggernaut", "Scorcheed Suggernaut", "Team 2", "Team 1")
	essence_value = [1, PlayerData.dungeon_layer_level]

func _set_stats():
	health_component.set_stats(
		get_total_health(),
		base_defense)
	attack_component.set_stats_absolute(
		get_total_attack_damage(),
		attack_range,
		base_critical_percent_chance,
		base_critical_damage_multiplier)
	
	attack_component.post_attack_target.connect(_damage_surrounding_targets)

func _damage_surrounding_targets(targets: Array[Entity], _is_crit: bool):
	var self_pos = BoardGrid.world_to_tile(position)
	var target_pos = BoardGrid.world_to_tile(targets[0].position)
	
	var tiles: Array[Vector2i] = BoardGrid.get_tiles_two_behind(self_pos, target_pos)
	var board_targets: Array = get_parent().get_parent().get_node("FriendlyUnits").get_children()

	for t in board_targets:
		if t == targets[0]:
			continue

		if t.hostile_team != "Team 2":
			continue

		var unit_tile = BoardGrid.world_to_tile(t.position)

		if unit_tile in tiles:
			t.health_component.take_damage_flat(
				self,
				attack_component.get_total_attack_damage(),
				false)
