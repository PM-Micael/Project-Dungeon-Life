extends Blessing
class_name MoltenLayer

var shield_flat: int = 0
var shield_percent: float = 0.2

func _init() -> void:
	id = "molten_layer"
	display_name = "Molten Layer"
	duration = -1  # Permanent — removed only when shield breaks
	stacks = 1

func apply(_target: Entity) -> void:
	var shield = Shield.new(shield_flat, shield_percent)
	shield.warer = owner
	shield.owner = owner
	shield.apply(owner)
	shield.shield_broken.connect(_on_shield_broken)
	buffs.append(shield)
	print("Molten Layer applied to " + owner.display_name)

func _on_shield_broken() -> void:
	AudioManager.play_sfx_once(owner, "res://Scenes/Units/PC/magma_golem/gamesound-broken-454907.mp3")

	print("Molten Layer shattered — Magma Golem ignites!")
	if owner.has_method("_on_molten_layer_broken"):
		owner._on_molten_layer_broken()
