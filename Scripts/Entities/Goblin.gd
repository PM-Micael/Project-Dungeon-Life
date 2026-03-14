extends Entity

var enemy_target

@export_category("Node Refferences")
@onready var health_bar: ProgressBar = $Components/HealthComponent/HealthBar
@onready var movment_component: MovmentComponent = $Components/MovmentComponent
@onready var attack_component: AttackComponent = $Components/AttackComponent
@onready var targeting_component: TargetingComponent = $Components/TargetingComponent

var timer: int = 0
var in_target_attack_range: bool

func _ready() -> void:
	super._ready()
	hostile_team = "Team 2"
	name = "Goblin"
	add_to_group("Team 1")
	
func _physics_process(_delta: float) -> void:
	_action()

func _action():
	# Set target
	targeting_component.select_target(hostile_team)
	
	if movment_component.timer.time_left <= 0.1 && targeting_component.target != null:
		in_target_attack_range = movment_component.move_to_target(targeting_component.target) # Set attack range
		movment_component.timer.start()
	
	if in_target_attack_range && attack_component.timer.time_left <= 0.1 && targeting_component.target != null:
		attack_component.attack_target(targeting_component.target)
		attack_component.timer.start()
