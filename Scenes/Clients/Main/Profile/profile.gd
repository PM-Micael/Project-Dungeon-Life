extends Node2D

@onready var user_name_label: RichTextLabel = $UserName/UserNameLabel
@onready var user_name_line_edit: LineEdit = $UserName/UserNameLineEdit

@onready var essence_label: Label = $InnerSanctum/EssenceLabel
@onready var life_label: Label = $InnerSanctum/LifeLabel
@onready var power_label: Label = $InnerSanctum/PowerLabel

@onready var highest_room_tier_1_label: Label = $HighScores/TheDungeon/Tier1/HighestRoomLabel

func _ready() -> void:
	_connect_events()

func _initialize_variables():
	user_name_label.text = "[u][b]"+PlayerData.player_display_name
	
	essence_label.text = "Essence: "+str(PlayerData.inner_sanctum_essence_current)
	life_label.text = "Life: "+str(PlayerData.inner_sanctum.life)
	power_label.text = "Power: "+str(PlayerData.inner_sanctum.power)
	
	highest_room_tier_1_label.text = "Room: "+str(PlayerData.dungeon_high_score["the_dungeon"]["tier_1"]["room"])

func _connect_events():
	PlayerData.player_data_loaded.connect(_initialize_variables)
	PlayerData.player_data_saved.connect(_initialize_variables)
	user_name_line_edit.text_submitted.connect(_on_text_submitted)

func _on_text_submitted(text: String):
	PlayerData.player_display_name = text
	PlayerData.save_player_data()
	user_name_line_edit.text = ""
	user_name_label.text = "[u][b]"+text
