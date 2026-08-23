class_name Effect
extends Resource

var id: String
var display_name: String
var description: String = ""
var owner: Unit
var warer: Unit
var duration: float:
	set(value):
		duration = value
		tick_down(duration)
var stacks: int = 1
var sprite: Sprite2D

func tick_down(_delta: float):
	pass

func apply(_target: Entity):
	pass

func remove() -> void:
	pass
