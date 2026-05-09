extends Entity
class_name Unit

const Unity = {
	PUTRID_SPAWN = "putrid_spawn"
}

@export_category("Info")
var passive_description: String
var starting_position: Vector2

@export_category("Tags")
var unity: String

func _ready() -> void:
	position = starting_position
	BoardGrid.set_tile_solid(BoardGrid.world_to_tile(position), true)

func _info(_name: String, _display_name: String, _friendly_team: String, _hostile_team: String):
	name = _name
	display_name = _display_name
	add_to_group(_friendly_team)
	hostile_team = _hostile_team

func _check_unity_in_battle() -> int:
	var children: Array[Node] = get_node("/root/TeamLineupMenu/Board/Units/FriendlyUnits").get_children()
	var unity_units: int = 0
	
	for unit in children:
		if unit.unity == unity:
			unity_units += 1
	
	return unity_units

func queue_free_unit():
	var tile = BoardGrid.world_to_tile(position)
	BoardGrid.set_tile_solid(tile, false)
	queue_free()
