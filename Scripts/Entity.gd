extends CharacterBody2D
class_name Entity

var enetity_name

func _ready() -> void:
	var timer = get_node("/root/Game/Board/Timer")
	timer.action_tick.connect(entity_action)

func entity_action():
	print("Entity action")
