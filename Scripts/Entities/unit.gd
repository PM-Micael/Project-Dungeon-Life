extends Entity
class_name Unit

const Unity = {
	PUTRID_SPAWN = "putrid_spawn",
	SCORCHED_ZONE = "scorched_zone"
}

@export_category("Info")
var passive_description: String
var starting_position: Vector2

@export_category("Stats")
@export var base_health: int
@export var base_defense: int
@export var attack_damage: int
@export var attack_range: int
@export var base_critical_percent_chance: int
@export var base_critical_damage_multiplier: float

@export_category("States")
@export var is_channeling: bool = false

@export_category("Tags")
var unity: String

@export_category("enemy_exclusive")
var is_player_unit: bool
var is_summon: bool = false
var essence_value: Array[float]
var is_boss: bool = false

func _ready() -> void:
	position = starting_position
	BoardGrid.set_tile_solid(BoardGrid.world_to_tile(position), true)

func _info(_name: String, _display_name: String, _friendly_team: String, _hostile_team: String):
	name = _name
	display_name = _display_name
	add_to_group(_friendly_team)
	hostile_team = _hostile_team

func get_total_health() -> int:
	if is_player_unit:
		return base_health*PlayerData.inner_sanctum.power
	return base_health*PlayerData.dungeon_enemy_multiplier

func get_total_attack_damage() -> int:
	if is_player_unit:
		return attack_damage*PlayerData.inner_sanctum.power
	return attack_damage*PlayerData.dungeon_enemy_multiplier

func _check_unity_in_battle() -> int:
	var children: Array[Node] = get_node("/root/MainClient/RunManager/BoardWindow/Board/Units/FriendlyUnits").get_children()
	var unity_units: int = 0
	
	for unit in children:
		if unit.unity == unity:
			unity_units += 1
	
	return unity_units

func queue_free_unit():
	var tile = BoardGrid.world_to_tile(position)
	BoardGrid.set_tile_solid(tile, false)
	queue_free()
