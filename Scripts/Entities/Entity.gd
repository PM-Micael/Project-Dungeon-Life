extends CharacterBody2D
class_name Entity

var enetity_name: String
var hostile_team: String

@export_category("Stats")
@export var attack: int = 1

@export_category("Other")
@export var starting_position: Vector2

func _ready() -> void:
	position = starting_position

func _attack_target(target: Entity):
	var target_health_bar: HealthBarComponent = target.get_node("Components/HealthComponent/HealthBar")
	target_health_bar.take_damage(self)
