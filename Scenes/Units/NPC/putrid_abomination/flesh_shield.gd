extends Blessing
class_name FleshShield

var flesh_goul_scene: PackedScene = preload("res://Scenes/Units/NPC/flesh_goul/flesh_goul.tscn")

var shield_value_flat: int = 0
var shield_value_percent: float = 0.2
var shield_recharge_timer: float = 7.0

func _init() -> void:
	id = "flesh_shield"
	display_name = "Flesh Shield"
	duration = 4
	stacks = 1
	set_buffs()

func set_buffs():
	var shield = Shield.new(shield_value_flat, shield_value_percent)
	shield.duration = 20
	shield.shield_broken.connect(_on_shield_broken)
	buffs.append(shield)

func apply(_target: Entity) -> void:
	apply_buffs()

func apply_buffs():
	for buff in buffs:
		buff.warer = owner
		buff.owner = owner
		buff.apply(owner)

func _on_shield_broken():
	print("Flesh Shield broken! Spawning ghouls.")
	var spawn_parent: Node2D = owner.get_parent()
	var board: GameBoard = spawn_parent.get_parent().get_parent()
	
	var offsets = [Vector2(100, 0), Vector2(-100, 0)]
	for offset in offsets:
		var goul: Unit = flesh_goul_scene.instantiate()
		spawn_parent.add_child(goul)
		goul.global_position = owner.global_position + offset
		board.enemy_units.append(goul)
		goul.health_component.died.connect(board._on_enemy_unit_died)
		
	_start_shield_recharge_timer()
	
func _start_shield_recharge_timer():
	var timer = Timer.new()
	timer.wait_time = shield_recharge_timer
	timer.one_shot = true
	owner.add_child(timer)
	timer.timeout.connect(_on_reapply_timer_timeout.bind(timer))
	timer.start()

func _on_reapply_timer_timeout(timer: Timer):
	timer.queue_free()
	apply_buffs()
	print("Flesh Shield reapplied!")
