# Handle the autobatteling portion
extends Node2D
class_name GameBoard

signal scale_changed
signal round_over(player_won: bool)

var set_scale_custom: Vector2:
	set(value):
		if value > Vector2(1.0, 1.0) or value < Vector2(0.1, 0.1):
			return
		if scale != value:
			scale = value
			scale_changed.emit(scale)

var collected_essence: int = 0
var game_on: bool = false

@onready var run_manager: RunManager = get_parent().get_parent()
@onready var enemy_units_node: Node2D = get_node("Units/EnemyUnits")
@onready var friendly_units_node: Node2D = get_node("Units/FriendlyUnits")
@onready var victory_screen: Node2D = get_node("RoundOver/VictoryScreen")
@onready var defeat_screen: Node2D = get_node("RoundOver/DefeatScreen")
@onready var next_stage_button = get_node("RoundOver/VictoryScreen/NextStageButton")
@onready var start_stage: Button = $StartStage

@onready var friendly_units: Array[Unit]
@onready var enemy_units: Array[Unit]

func _ready() -> void:
	set_up_board()

func set_up_board():
	await PlayerData.player_data_loaded
	
	for unit in friendly_units:
		unit.health_component.died.connect(_on_friendly_unit_died)
	for unit in enemy_units:
		unit.health_component.died.connect(_on_enemy_unit_died)

func _physics_process(_delta: float) -> void:
	if game_on:
		_check_units_alive()

func _place_friendly_units():
	var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")
	var team_formation: Array[Dictionary]
	if PlayerData.dungeon_run_ongoing_the_dungeon:
		team_formation = PlayerData.dungeon_team_formation_the_dungeon
	elif PlayerData.dungeon_run_ongoing_putrid_layers:
		team_formation = PlayerData.dungeon_team_formation_putrid_layers
	elif PlayerData.dungeon_run_ongoing_scorched_grounds:
		team_formation = PlayerData.dungeon_team_formation_scorched_grounds
	
	for u in team_formation:
		var unit_name: String = u["unit_name"]
		var unit_starting_position = u["starting_position"]
		var weapon_id = u["weapon_id"]
		
		var unit_scene: PackedScene = load("res://Scenes/Units/PC/" + unit_name + "/" + unit_name + ".tscn")
		var unit_instance: Unit = unit_scene.instantiate()
		
		if weapon_id != "":
			var weapon_scene: PackedScene = load("res://Scenes/Weapons/"+weapon_id+"/"+weapon_id+".tscn")
			var weapon_instance: Entity = weapon_scene.instantiate()
			
			var wc: WeaponComponent = weapon_instance.get_node_or_null("Components/WeaponComponent")
			if wc != null:
				wc.star_level = u.get("weapon_star_level", 1)
			
			var weapon_slot = unit_instance.get_node("Components/WeaponSlotComponent")
			weapon_slot.add_child(weapon_instance)
		
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()
		
		entity_container_instance.name = "EntityContainer_" + unit_name
		entity_container_instance.entity = unit_instance
		entity_container_instance.position = unit_starting_position
		entity_container_instance.scale = unit_instance.scale
		entity_container_instance.get_node("Sprite2D").scale = Vector2(1.5, 1.5)
		unit_instance.starting_position = entity_container_instance.position
		
		get_node("Units/FriendlyUnits").add_child(entity_container_instance)
		friendly_units.append(unit_instance)

func place_enemy_units(dungeon: String): ## Wait for dungeon chosen
	var enemy_formation: Array = DungeonData.get_room_formations(dungeon, PlayerData.dungeon_room)
	var entity_container_scene: PackedScene = load("res://Scripts/Entities/entity_container.tscn")

	var loop_itteration: int = 0
	for e in enemy_formation:
		var enemy_type: String = e["type"]
		var enemy_position: Vector2 = e["position"]
		var enemy_scene: PackedScene = load("res://Scenes/Units/NPC/" + enemy_type + "/" + enemy_type + ".tscn")
		var enemy_instance: Unit = enemy_scene.instantiate()
		var entity_container_instance: EntityContainer = entity_container_scene.instantiate()

		entity_container_instance.name = "EntityContainer_" + str(loop_itteration + 1)
		entity_container_instance.entity = enemy_instance
		entity_container_instance.position = enemy_position
		entity_container_instance.scale = enemy_instance.scale
		entity_container_instance.get_node("Sprite2D").scale = Vector2(1.5, 1.5)
		enemy_instance.starting_position = entity_container_instance.position

		get_node("Units/EnemyUnits").add_child(entity_container_instance)
		enemy_units.append(enemy_instance)
		loop_itteration += 1

func _on_friendly_unit_died(unit: Unit):
	friendly_units.erase(unit)

func _on_enemy_unit_died(unit: Unit):
	collected_essence += randi_range(unit.essence_value[0], unit.essence_value[1])
	enemy_units.erase(unit)

func place_friendly_units_on_board():
	for u in friendly_units:
		friendly_units_node.add_child(u)

func place_enemy_units_on_board():
	for u in enemy_units:
		enemy_units_node.add_child(u)
		u.health_component.died.connect(_on_enemy_unit_died)

func _check_units_alive():
	var enemies: Array = enemy_units_node.get_children()
	var friendlies: Array = friendly_units_node.get_children()

	if enemies.size() == 0:
		_on_victory()
	elif friendlies.size() == 0:
		_on_defeat()

func _on_victory():
	PlayerData.add_inner_sanctum_essence(collected_essence)
	print("Collected "+str(collected_essence)+" essence")
	print("Total essence = " + str(PlayerData.inner_sanctum_essence_current)+"/"+str(PlayerData.inner_sanctum_essence_total))
	collected_essence = 0
	PlayerData.dungeon_room += 1
	victory_screen.visible = true
	for node in friendly_units_node.get_children():
		node.queue_free_unit()
	game_on = false
	round_over.emit(true)
	
	var loot: Array[Dictionary] = LootTable.roll_loot("the_dungeon", PlayerData.dungeon_room)
	print("Loot gained:")
	print(str(loot))
	PlayerData.dungeon_loot.append_array(loot)
	PlayerData.add_loot_to_inventory(loot)
	DungeonData.check_and_merge_backpack_items()
	PlayerData.save_player_data()
	run_manager.inventory.fill_backpack_frame()
	
	if PlayerData.settings.auto_advance:
		await get_tree().create_timer(0.5).timeout
		next_stage_button.pressed.emit()

func _on_defeat():
	print("You loose")
	print("Collected essence = "+str(PlayerData.inner_sanctum_essence_current))
	defeat_screen.visible = true
	game_on = false
	round_over.emit(true)
	for node: Unit in enemy_units_node.get_children():
		node.queue_free_unit()
