extends Entity
class_name Unit

@export_category("Info")
var passive_description: String
var starting_position: Vector2

@export_category("")

func _init() -> void:
	id = "unt_zac"

func _ready() -> void:
	position = starting_position

func _info(_name: String, _display_name: String, _friendly_team: String, _hostile_team: String):
	name = _name
	display_name = _display_name
	add_to_group(_friendly_team)
	hostile_team = _hostile_team
	
