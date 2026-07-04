extends Node2D

var settings: Dictionary

@onready var mv_line_edit: LineEdit = $Options/ScrollContainer/VBoxContainer/Audio/MasterVolume/MVLineEdit
@onready var mv_increment_button: Button = $Options/ScrollContainer/VBoxContainer/Audio/MasterVolume/IncrementButton
@onready var mv_decrement_button: Button = $Options/ScrollContainer/VBoxContainer/Audio/MasterVolume/DecrementButton

@onready var sfx_line_edit: LineEdit = $Options/ScrollContainer/VBoxContainer/Audio/SFXVolume/SFXVolumeLineEdit
@onready var sfx_increment_button: Button = $Options/ScrollContainer/VBoxContainer/Audio/SFXVolume/IncrementButton
@onready var sfx_decrement_button: Button = $Options/ScrollContainer/VBoxContainer/Audio/SFXVolume/DecrementButton

@onready var music_line_edit: LineEdit = $Options/ScrollContainer/VBoxContainer/Audio/MusicVolume/MusicVolumeLineEdit
@onready var music_increment_button: Button = $Options/ScrollContainer/VBoxContainer/Audio/MusicVolume/IncrementButton
@onready var music_decrement_button: Button = $Options/ScrollContainer/VBoxContainer/Audio/MusicVolume/DecrementButton

@onready var apply_button: Button = $Options/ApplyButton

func _ready() -> void:
	if not LocalData.local_data_has_loaded:
		await LocalData.local_data_loaded
	
	_initialize_data()
	
	mv_line_edit.text_changed.connect(_on_line_edit_text_changed.bind(mv_line_edit))
	sfx_line_edit.text_changed.connect(_on_line_edit_text_changed.bind(sfx_line_edit))
	music_line_edit.text_changed.connect(_on_line_edit_text_changed.bind(music_line_edit))
	
	mv_increment_button.pressed.connect(_modify_button_pressed.bind(mv_line_edit, "+"))
	mv_decrement_button.pressed.connect(_modify_button_pressed.bind(mv_line_edit, "-"))
	
	sfx_increment_button.pressed.connect(_modify_button_pressed.bind(sfx_line_edit, "+"))
	sfx_decrement_button.pressed.connect(_modify_button_pressed.bind(sfx_line_edit, "-"))
	
	music_increment_button.pressed.connect(_modify_button_pressed.bind(music_line_edit, "+"))
	music_decrement_button.pressed.connect(_modify_button_pressed.bind(music_line_edit, "-"))
	
	apply_button.pressed.connect(_apply_button_pressed)

func _initialize_data():
	mv_line_edit.text = str(LocalData.settings["audio"]["volume_master"])
	sfx_line_edit.text = str(LocalData.settings["audio"]["volume_sfx"])
	music_line_edit.text = str(LocalData.settings["audio"]["volume_music"])

func _on_line_edit_text_changed(new_text: String, line_edit: LineEdit) -> void:
	var filtered := ""

	for c in new_text:
		if c.is_valid_float():
			filtered += c

	if filtered != new_text:
		line_edit.text = filtered
		line_edit.caret_column = filtered.length()

func _modify_button_pressed(line_edit: LineEdit, modifier: String):
	var value = float(line_edit.text)
	if modifier == "+":
		value += 0.1
		if value >= 20.0:
			value = 20.0 
	elif modifier == "-":
		value -= 0.1
		if value < 0.0:
			value = 0
		
	line_edit.text = str(value)

func _apply_button_pressed():
	settings = {
		"audio":{
			"volume_master": float(mv_line_edit.text),
			"volume_sfx": float(sfx_line_edit.text),
			"volume_music": float(music_line_edit.text)
		}
	}
	LocalData.apply_settings(settings)
	_initialize_data()
