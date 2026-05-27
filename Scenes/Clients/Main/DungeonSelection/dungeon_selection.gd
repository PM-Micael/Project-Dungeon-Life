extends Node2D

var dungeons: Array[String]

func _ready() -> void:
	for zone in DungeonData.Zone.keys():
		dungeons.append(zone)

func display_dungeons():
	var loop_itterations: int = 0
	for i in dungeons:
		var button = Button.new()
		button.name = i
		button.scale = Vector2(2, 2)
		button.text = i
		button.position = Vector2(100 + (200*loop_itterations), 100)
		add_child(button)
