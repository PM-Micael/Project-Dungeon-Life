class_name Effect
extends Resource

var id: String
var display_name: String
var description: String = ""
var owner: Unit
var warer: Unit
var duration: float
var stacks: int = 1
var sprite: Sprite2D

func apply(_target: Entity):
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = id+"_Sprite2D"
	if owner and not sprite.is_inside_tree():
		owner.add_child(sprite)

func remove() -> void:
	if is_instance_valid(sprite):
		sprite.queue_free()
	sprite = null
