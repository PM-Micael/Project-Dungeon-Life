extends Node2D

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
	mv_line_edit.text = str(1.0)
	sfx_line_edit.text = str(1.0)
	music_line_edit.text = str(1.0)

	mv_line_edit.text_changed.connect(_on_line_edit_text_changed.bind(mv_line_edit))
	sfx_line_edit.text_changed.connect(_on_line_edit_text_changed.bind(sfx_line_edit))
	music_line_edit.text_changed.connect(_on_line_edit_text_changed.bind(music_line_edit))
	
	mv_increment_button.pressed.connect(_modify_button_pressed.bind(mv_line_edit, "+"))
	mv_decrement_button.pressed.connect(_modify_button_pressed.bind(mv_line_edit, "-"))
	
	sfx_increment_button.pressed.connect(_modify_button_pressed.bind(sfx_line_edit, "+"))
	sfx_decrement_button.pressed.connect(_modify_button_pressed.bind(sfx_line_edit, "-"))
	
	music_increment_button.pressed.connect(_modify_button_pressed.bind(music_line_edit, "+"))
	music_decrement_button.pressed.connect(_modify_button_pressed.bind(music_line_edit, "-"))

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
	elif modifier == "-":
		value -= 0.1
		if value < 0:
			value = 0
		
	line_edit.text = str(value)
