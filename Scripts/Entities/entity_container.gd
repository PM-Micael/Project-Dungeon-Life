extends Control
class_name EntityContainer

@onready var star_level_label: Label

@onready var entity: Entity:
	set(value):
		entity = value
		_set_sprite()

func _set_sprite():
	var sprite: Sprite2D = get_child(0)
	if entity != null:
		sprite.position = entity.get_node("Sprite2D").position
		sprite.texture = entity.get_node("Sprite2D").texture
		
		star_level_label = get_node("Sprite2D/StarLevelLabel")
		star_level_label.text = ""
		var wc: WeaponComponent = entity.get_node_or_null("Components/WeaponComponent")
		if wc != null:
			for i in range(wc.star_level):
				star_level_label.text += "★"
		
		return
	
	sprite.texture = null

func on_clicked():
	get_parent().entity_container_clicked(self)

func on_right_click_option_selected(id: int):
	get_parent().on_right_click_option_selected(id, self)
	print("EntityContainer right clicked")
