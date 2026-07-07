class_name Effect
extends Resource

signal ticked

var id: String
var display_name: String
var owner: Unit
var warer: Unit
var duration: float
var stacks: int = 1

func apply(target: Entity) -> void:
	pass

func tick(target: Entity, delta: float) -> void:
	duration -= 1
	ticked.emit()
