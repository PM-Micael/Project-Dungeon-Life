extends Button

var auto: bool:
	set(value):
		auto = value
		if auto:
			text = "On"
			modulate = Color.GREEN
		else:
			text = "Off"
			modulate = Color.RED

func _ready() -> void:
	auto = PlayerData.settings["auto_advance"]
	pressed.connect(_on_pressed)


func _on_pressed():
	PlayerData.settings["auto_advance"] = not PlayerData.settings["auto_advance"]
	auto = PlayerData.settings["auto_advance"]
