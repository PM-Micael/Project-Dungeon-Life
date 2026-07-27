extends Node

signal local_data_loaded

var local_data_has_loaded: bool

const DISPLAY_MODE = {
	BORDERLESS = "borderless",
	WINDOWED = "windowed"
}

var settings: Dictionary = {
	"auto_advance": false,
	"audio": {
		"volume_master": 1.0,
		"volume_sfx": 1.0,
		"volume_music": 1.0
	},
	"display": {
		
	}
}

func load_local_data():
	settings = load_settings()
	local_data_has_loaded = true
	local_data_loaded.emit()

func apply_settings():
	settings = {
		"auto_advance":false,
		"display": {
			"display_mode": DISPLAY_MODE.BORDERLESS
		},
		"audio":{
			"volume_master":1.0,"volume_music":3.0,"volume_sfx":1.0
		},
	}
	
	var window = get_window()
	window.borderless = settings["display"]["display_mode"] == DISPLAY_MODE.BORDERLESS
	window.size = Vector2(1919, 1079)
	window.transient = true
	window.always_on_top = true
	
	var viewport := get_viewport()
	viewport.transparent_bg = true

func apply_new_settings(_settings: Dictionary):
	for setting in _settings.keys():
		settings[setting] = _settings[setting]
	print(str(settings))
	save_settings()

func save_settings():
	var data = JSON.stringify(settings)
	var file = FileAccess.open("res://local_data.json", FileAccess.WRITE)
	file.store_string(data)
	file.close()

func load_settings():
	if not FileAccess.file_exists("res://local_data.json"):
		print("No save file found, using defaults.")
		return settings
	
	var file = FileAccess.open("res://local_data.json", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var result = JSON.parse_string(content)
	
	if result == null or typeof(result) != TYPE_DICTIONARY:
		print("Invalid save file, using defaults.")
		return settings
	
	settings = result
	print("Loaded settings:", settings)
	return settings

func string_to_vector2(s: String) -> Vector2:
	s = s.trim_prefix("(").trim_suffix(")")
	var parts = s.split(",")

	if parts.size() != 2:
		return Vector2.ZERO

	return Vector2(
		parts[0].to_float(),
		parts[1].strip_edges().to_float()
	)
