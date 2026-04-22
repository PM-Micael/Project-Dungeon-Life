extends Node2D

func _ready() -> void:
	var loop_itteration: int = 0
	for i in Globals.dungeon_team:
		print(str(loop_itteration) + ": [" + i.name + "]. Position = [" + str(i.position) + "]")
		loop_itteration += 1
