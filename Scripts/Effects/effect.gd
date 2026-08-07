class_name Effect
extends Resource

var id: String
var display_name: String
var description: String = ""
var owner: Unit
var warer: Unit
var duration: float
var stacks: int = 1

func apply(_target: Entity) -> void:
	pass

func remove():
	pass
