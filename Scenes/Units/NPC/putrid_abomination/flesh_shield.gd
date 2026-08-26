extends Blessing
class_name FleshShield

var flesh_goul_scene: PackedScene = preload("res://Scenes/Units/NPC/flesh_goul/flesh_goul.tscn")

var shield_value_flat: int = 0
var shield_value_percent: float = 0.15

func _init() -> void:
	id = "flesh_shield"
	display_name = "Flesh Shield"
	duration = 6
	stacks = 1
	set_buffs()

func set_buffs():
	var shield = Shield.new(shield_value_flat, shield_value_percent)
	shield.duration = 10
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
		var ghoul: Unit = flesh_goul_scene.instantiate()
		spawn_parent.add_child(ghoul)
		ghoul.global_position = owner.global_position + offset
		ghoul.is_summon = true
		board.enemy_units.append(ghoul)
		ghoul.health_component.died.connect(board._on_enemy_unit_died)
		
func remove():
	pass
