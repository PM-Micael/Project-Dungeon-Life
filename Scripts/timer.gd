extends Timer

signal action_tick

func _ready() -> void:
	timeout.connect(_on_timeout)
	start()

func _on_timeout():
	action_tick.emit()
