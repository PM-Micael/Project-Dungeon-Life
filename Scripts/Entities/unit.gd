extends Entity
class_name Unit

signal channel_started(duration: float)
signal channel_complete(title: String)
signal channel_interrupted(title: String)

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
var is_stunned: bool = false
var stun_duration: float = 0

@export_category("Tags")
var unity: String

@export_category("enemy_exclusive")
var is_player_unit: bool
var is_summon: bool = false
var essence_value: Array[float]
var is_boss: bool = false

@export_category("channel")
var channel_bar: ProgressBar
var channel_duration: float = 0
var is_channel_interrupted: bool
var is_channeling: bool:
	set(value):
		is_channeling = value
		if value:
			channel_started.emit()

var _stats_initialized: bool = false

var attack_sprite_scene: Dictionary = {}

func _ready() -> void:
	initialize_stats()
	channel_bar = ui_component.channel_bar
	position = starting_position
	BoardGrid.set_tile_solid(BoardGrid.world_to_tile(position), true)

## Applies this unit's stats to its components. Call right after instantiate() so the
## unit has valid stats while it is still detached from the tree (the lineup phase
## reads them from an unparented Unit). Runs only once; _ready() is the fallback for
## anything spawned straight into the tree.
func initialize_stats() -> void:
	if _stats_initialized:
		return
	_stats_initialized = true
	_set_stats()

## Overridden per unit. Must stay safe to call while detached: no @onready vars,
## no get_tree(), no BoardGrid, no signal connections.
func _set_stats() -> void:
	pass

func _physics_process(delta: float) -> void:
	if is_stunned:
		stun_duration -= delta
		if stun_duration <= 0:
			is_stunned = false
	
	if is_channeling:
		channel_tick(delta)

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

func stun_unit(duration: float):
	is_stunned = true

## Channel
func start_channel(duration: float, channel_text: String):
	is_channeling = true
	is_channel_interrupted = false
	channel_duration = duration
	channel_bar.max_value = duration
	channel_bar.value = 0
	ui_component.channel_title.text = channel_text
	channel_bar.visible = true

func channel_tick(delta: float):
	channel_bar.value += delta
	if channel_bar.value >= channel_bar.max_value:
		is_channeling = false
		channel_bar.visible = false
		ui_component.channel_title.visible = false
		channel_complete.emit(ui_component.channel_title.text)

func interrupt_channel(title: String):
	is_channeling = false
	channel_bar.visible = false
	ui_component.channel_title.visible = false
	channel_interrupted.emit(title)
