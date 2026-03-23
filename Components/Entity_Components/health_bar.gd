extends ProgressBar
class_name HealthBarComponent

@onready var parent_entity: Entity = get_parent().get_parent().get_parent()

@export var max_health: int = 10
@export var current_health: int

var is_alive: bool = true

func _ready() -> void:
	current_health = max_health
	max_value = max_health
	value = current_health

func take_damage(attacker: Entity):
	current_health -= attacker.attack_component.attack_damage
	current_health = clamp(current_health, 0, max_health)
	
	value = current_health
	
	if current_health <= 0:
		is_alive = false
