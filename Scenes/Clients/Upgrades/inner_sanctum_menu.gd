extends Node2D
class_name InnerSanctum

var life_upgrade_cost: float = PlayerData.inner_sanctum.life
var allocated_life_points: float:
	set(value):
		allocated_life_points = value
		life_value_label.text = str(PlayerData.inner_sanctum.life + allocated_life_points)

var power_upgrade_cost: float = PlayerData.inner_sanctum.power
var allocated_power_points: float:
	set(value):
		allocated_power_points = value
		power_value_label.text = str(PlayerData.inner_sanctum.power + allocated_power_points)

var allocated_essence: int:
	set(value):
		allocated_essence = value
		essence_value_label.text = "Essence: "+str(allocated_essence) +"/"+ str(PlayerData.inner_sanctum_essence_current)

@onready var essence_value_label: Label = get_node("EssenceValueLabel")
@onready var commit_button: Button = get_node("CommitButton")
@onready var dungeon_button: Button = get_node("DungeonButton")

@onready var life_key_label: Label = get_node("InnerSanctumLife/KeyLabel")
@onready var life_value_label: Label = get_node("InnerSanctumLife/ValueLabel")
@onready var life_decrease_button: Button = get_node("InnerSanctumLife/DecreaseButton")
@onready var life_increase_button: Button = get_node("InnerSanctumLife/IncreaseButton")

@onready var power_key_label: Label = get_node("InnerSanctumPower/KeyLabel")
@onready var power_value_label: Label = get_node("InnerSanctumPower/ValueLabel")
@onready var power_decrease_button: Button = get_node("InnerSanctumPower/DecreaseButton")
@onready var power_increase_button: Button = get_node("InnerSanctumPower/IncreaseButton")

func _ready() -> void:
	await PlayerData.player_data_loaded
	PlayerData.dungeon_run_ongoing_changed.connect(_setup)
	_setup()

func _setup(_state: bool = false, _dungeon: String = ""):
	allocated_essence = PlayerData.inner_sanctum_essence_current
	commit_button.pressed.connect(_commit_pressed)
	
	life_key_label.text = "Life"
	allocated_life_points = 0
	life_increase_button.pressed.connect(increase_life_pressed)
	life_decrease_button.pressed.connect(decrease_life_pressed)
	
	power_key_label.text = "Power"
	allocated_power_points = 0
	power_increase_button.pressed.connect(increase_power_pressed)
	power_decrease_button.pressed.connect(decrease_power_pressed)

func _commit_pressed():
	PlayerData.inner_sanctum.life += allocated_life_points
	allocated_life_points = 0
	
	PlayerData.inner_sanctum.power += allocated_power_points
	allocated_power_points = 0
	
	PlayerData.inner_sanctum_essence_current = allocated_essence
	PlayerData.save_player_data()
	_setup()

# Life
func increase_life_pressed():
	if allocated_essence <= 0:
		return
	
	var virtual_essence = allocated_essence
	virtual_essence -= int(life_upgrade_cost)
	if virtual_essence < 0:
		return
		
	allocated_life_points += 0.1 
	allocated_essence = virtual_essence
	_set_life_upgrade_cost()

func decrease_life_pressed():
	allocated_life_points -= 0.1
	if allocated_life_points < 0:
		allocated_life_points = 0
		return
	_set_life_upgrade_cost()
	allocated_essence += int(life_upgrade_cost)

func _set_life_upgrade_cost():
	life_upgrade_cost = PlayerData.inner_sanctum.life + allocated_life_points

# Power
func increase_power_pressed():
	if allocated_essence <= 0:
		return
		
	var virtual_essence = allocated_essence
	virtual_essence -= int(power_upgrade_cost)
	if virtual_essence < 0:
		return
		
	allocated_power_points += 0.1
	allocated_essence = virtual_essence
	_set_power_upgrade_cost()

func decrease_power_pressed():
	allocated_power_points -= 0.1
	if allocated_power_points < 0:
		allocated_power_points = 0
		return
	_set_power_upgrade_cost()
	allocated_essence += int(power_upgrade_cost)

func _set_power_upgrade_cost():
	power_upgrade_cost = PlayerData.inner_sanctum.power + allocated_power_points
