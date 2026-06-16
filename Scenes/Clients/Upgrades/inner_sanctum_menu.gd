extends Node2D
class_name InnerSanctum

var life_upgrade_cost: float
var allocated_life_points: float:
	set(value):
		allocated_life_points = value
		life_value_label.text = str(PlayerData.inner_sanctum.life + allocated_life_points)

var power_upgrade_cost: float
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

@onready var life_key_label: Label = get_node("InnerSanctumLife/KeyLabel")
@onready var life_value_label: Label = get_node("InnerSanctumLife/ValueLabel")
@onready var life_decrease_button: Button = get_node("InnerSanctumLife/DecreaseButton")
@onready var life_decrease_button_x10: Button = get_node("InnerSanctumLife/DecreaseButtonX10")
@onready var life_increase_button: Button = get_node("InnerSanctumLife/IncreaseButton")
@onready var life_increase_button_x10: Button = get_node("InnerSanctumLife/IncreaseButtonX10")

@onready var power_key_label: Label = get_node("InnerSanctumPower/KeyLabel")
@onready var power_value_label: Label = get_node("InnerSanctumPower/ValueLabel")
@onready var power_decrease_button: Button = get_node("InnerSanctumPower/DecreaseButton")
@onready var power_decrease_button_x10: Button = get_node("InnerSanctumPower/DecreaseButtonX10")
@onready var power_increase_button: Button = get_node("InnerSanctumPower/IncreaseButton")
@onready var power_increase_button_x10: Button = get_node("InnerSanctumPower/IncreaseButtonX10")

func _ready() -> void:
	await PlayerData.player_data_loaded
	PlayerData.dungeon_run_ongoing_changed.connect(_setup)
	_setup()

func _setup(_state: bool = false, _dungeon: String = ""):
	allocated_essence = PlayerData.inner_sanctum_essence_current
	commit_button.pressed.connect(_commit_pressed)
	
	life_key_label.text = "Life"
	allocated_life_points = 0
	life_upgrade_cost = PlayerData.inner_sanctum.life
	life_increase_button.pressed.connect(func(): increase_life_pressed(1))
	life_increase_button_x10.pressed.connect(func(): increase_life_pressed(10))
	life_decrease_button.pressed.connect(func(): decrease_life_pressed(1))
	life_decrease_button_x10.pressed.connect(func(): decrease_life_pressed(10))
	
	power_key_label.text = "Power"
	allocated_power_points = 0
	power_upgrade_cost = PlayerData.inner_sanctum.power
	power_increase_button.pressed.connect(func(): increase_power_pressed(1))
	power_increase_button_x10.pressed.connect(func(): increase_power_pressed(10))
	power_decrease_button.pressed.connect(func(): decrease_power_pressed(1))
	power_decrease_button_x10.pressed.connect(func(): decrease_power_pressed(10))

func _commit_pressed():
	if allocated_essence == PlayerData.inner_sanctum_essence_current:
		return
	PlayerData.inner_sanctum.life += allocated_life_points
	allocated_life_points = 0
	
	PlayerData.inner_sanctum.power += allocated_power_points
	allocated_power_points = 0
	
	PlayerData.inner_sanctum_essence_current = allocated_essence
	PlayerData.save_player_data()
	_setup()

# Life
func increase_life_pressed(multiplier: int):
	if allocated_essence <= 0:
		return
	
	var virtual_essence = allocated_essence
	virtual_essence -= int(life_upgrade_cost*multiplier)
	if virtual_essence < 0:
		return
		
	allocated_life_points += 0.1*multiplier
	allocated_essence = virtual_essence
	_set_life_upgrade_cost()

func decrease_life_pressed(multiplier: int):
	allocated_life_points -= 0.1*multiplier
	if allocated_life_points < 0:
		allocated_life_points = 0
	_set_life_upgrade_cost()
	allocated_essence += int(life_upgrade_cost*multiplier)
	if allocated_essence > PlayerData.inner_sanctum_essence_current:
		allocated_essence = PlayerData.inner_sanctum_essence_current

func _set_life_upgrade_cost():
	life_upgrade_cost = PlayerData.inner_sanctum.life + allocated_life_points

# Power
func increase_power_pressed(multiplier: int):
	if allocated_essence <= 0:
		return
		
	var virtual_essence = allocated_essence
	virtual_essence -= int(power_upgrade_cost*multiplier)
	if virtual_essence < 0:
		return
		
	allocated_power_points += 0.1*multiplier
	allocated_essence = virtual_essence
	_set_power_upgrade_cost()

func decrease_power_pressed(multiplier: int):
	allocated_power_points -= 0.1*multiplier
	if allocated_power_points < 0:
		allocated_power_points = 0
	_set_power_upgrade_cost()
	allocated_essence += int(power_upgrade_cost*multiplier)
	if allocated_essence > PlayerData.inner_sanctum_essence_current:
		allocated_essence = PlayerData.inner_sanctum_essence_current

func _set_power_upgrade_cost():
	power_upgrade_cost = PlayerData.inner_sanctum.power + allocated_power_points
