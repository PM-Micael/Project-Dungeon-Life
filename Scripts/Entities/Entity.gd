extends CharacterBody2D
class_name Entity

var hostile_team: String

@export_category("Other")
@export var starting_position: Vector2

func _ready() -> void:
	position = starting_position
